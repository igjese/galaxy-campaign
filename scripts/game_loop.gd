extends Node

enum GameState { SETUP, START_TURN, IDLE, PROCESS_MOVES, COMBAT, MOVE, END_TURN}
var states = ["SETUP","START_TURN", "IDLE", "PROCESS_MOVES", "COMBAT", "MOVE", "END_TURN"]
var state = GameState.IDLE
var map: Node = null
var combat_dialog: Node = null
var pending_moves: Array = []
var current_move = null
var seed = 1234
var turn := 1
var player_materials := 10
var player_supply := 10
var player_personnel := 10
var global_parity := 80.0
var parity_ramp := 2.0
var first_player_attack_done := false
var selected_world = null
var all_ships = []  # each ship is a dict or lightweight object
var goal_defs = {}
var run_debug := false

func change_state(new_state: int):
    print("State: %s to %s" % [states[state], states[new_state]])
    state = new_state
    match state:
        GameState.SETUP:
            begin_setup()
        GameState.START_TURN:
            print("Turn: %d" % turn)
            begin_start_turn()
        GameState.IDLE:
            pass
        GameState.PROCESS_MOVES:
            print(pending_moves)
            begin_process_moves()
        GameState.COMBAT:
            print(current_move)
            begin_combat()
        GameState.MOVE:
            print(current_move)
            begin_move()
        GameState.END_TURN:
            begin_end_turn()


func begin_setup():
    map = get_tree().get_root().get_node("Main/Map")
    combat_dialog = map.get_node("UI/CombatDialog")
    goal_defs = Yaml.load_yaml("res://rules/goals.yaml")
    print("[GameLoop] Loaded ", goal_defs.size(), " AI goals")

func begin_start_turn():
    turn += 1
    global_parity += parity_ramp
    print("📈 Turn %d — Global Parity now: %.1f%%" % [turn, global_parity])
    collect_resources()
    decide_ai_attacks()
    map.update_gui()
    change_state(GameState.IDLE)
    
    
func decide_ai_attacks():
    if turn >= 5:
        for system in map.system_map.values():
            if system.faction != "ai":
                continue
            # Find player-controlled neighbors
            var targets = []
            for conn in system.connections:
                var neighbor = map.system_map.get(conn)
                if neighbor and neighbor.faction == "player":
                    targets.append(neighbor)
            if targets.is_empty():
                continue
            if randf() < 0.2:
                var target = targets[randi() % targets.size()]
                var player_cost := get_player_fleet_cost_at(target.name)
                var ai_fleet := generate_ai_fleet(player_cost)
                print("⚠️ AI attack scheduled: %s → %s (player cost: %d, parity: %.1f%%)" %
                    [system.world_name, target.world_name, player_cost, global_parity])
                map._on_move_queued(system.world_name, target.world_name, ai_fleet)


func get_player_fleet_cost_at(system_name: String) -> int:
    var total := 0
    for ship in all_ships:
        if ship.faction == "player" and ship.location == system_name:
            var design = GameData.ship_designs.get(ship.type, {})
            total += design.cost_mats + design.cost_pers
    return total

    
func begin_end_turn():
    if not pending_moves.is_empty():
        change_state(GameState.PROCESS_MOVES)
    else:
        change_state(GameState.START_TURN)
        

func begin_process_moves():
    current_move = pending_moves.pop_front()
    current_move.indicator.queue_free()
    var to_star = map.system_map.get(current_move.to)
    var from_star = map.system_map.get(current_move.from)
    if to_star.faction == "ai" or from_star.faction == "ai":
        change_state(GameState.COMBAT)
    else:
        change_state(GameState.MOVE)

        
        
func begin_move():
    transfer_ships()
    change_state(GameState.END_TURN)


func transfer_ships():
    var ships = current_move.ships
    for ship_type in ships.counts.keys():
        var count = ships.counts[ship_type]
        for i in count:
            all_ships.append({
                "type": ship_type,
                "faction": "player",
                "location": current_move.to
            })
    print("Ships arrived at %s (%s)" % [current_move.to, ships.text])


func begin_combat():
    var to_star = map.system_map.get(current_move.to)
    var from_star = map.system_map.get(current_move.from)

    var is_ai_attacking = from_star.faction == "ai" and to_star.faction == "player"

    var player_group: ShipGroup
    if is_ai_attacking:
        var defenders = all_ships.filter(
            func(ship): return ship.faction == "player" and ship.location == to_star.world_name
        )
        player_group = ShipGroup.new_from_fleet(defenders)
        current_move.opponent = player_group
    else:
        player_group = current_move.ships  # player is attacking
        var player_cost = player_group.cost()["mats"] + player_group.cost()["pers"]
        current_move.opponent = generate_ai_fleet(player_cost)

    if is_ai_attacking and player_group.counts.is_empty():
        print("📭 %s fell without resistance!" % to_star.name)
        to_star.faction = "ai"
        map.update_gui()
        change_state(GameState.END_TURN)
        return

    combat_dialog.open()
    
    
func get_cheapest_ship_cost() -> int:
    var ff = GameData.ship_designs["FF"]
    return ff.cost_mats + ff.cost_pers


func generate_ai_fleet(player_cost: int) -> ShipGroup:
    var adjusted_cost := 0
    if not first_player_attack_done:
        print("🟢 First conquest: AI fleet at 80% parity")
        adjusted_cost = int(player_cost * 0.8)
        first_player_attack_done = true
    else:
        var swing := randf_range(0.8, 1.2)
        adjusted_cost = int(player_cost * swing * global_parity / 100.0)
        print("⚖️ Scaled AI fleet: %.0f%% parity, %.0f%% swing → %d pts" %
            [global_parity, swing * 100.0, adjusted_cost])
    var cheapest_cost = get_cheapest_ship_cost()
    var min_defense_cost = cheapest_cost * (2 + turn / 5)  # +1x every 5 turns
    adjusted_cost = max(adjusted_cost, min_defense_cost)            
    var result := ShipGroup.new()
    var types = GameData.ship_designs.keys()
    while adjusted_cost > 0:
        var type = types[randi() % types.size()]
        var design = GameData.ship_designs[type]
        var cost = design.cost_mats + design.cost_pers
        if cost <= adjusted_cost:
            result.counts[type] = result.counts.get(type, 0) + 1
            adjusted_cost -= cost
        else:
            break
    return result


func queue_move(from: String, to: String, ships: ShipGroup, indicator: Node):
    # Add move
    pending_moves.append({
        "from": from,
        "to": to,
        "ships": ships,
        "indicator": indicator
    })
    # Skip special cases for AI
    if from == "ai_fake":
        # (Optional: add visual indicator to the system here)
        return
    # Remove ships in transit
    var remaining := []
    var pending_counts := ships.counts.duplicate()
    for ship in all_ships:
        if ship.faction == "player" and ship.location == from:
            var t = ship.type
            if pending_counts.has(t) and pending_counts[t] > 0:
                pending_counts[t] -= 1
                continue
        remaining.append(ship)
    all_ships = remaining
    map.update_gui()
    if not GameLoop.run_debug:
        map.get_node("UI/WorldDialog").clear_line_items()


func _on_shipyard_order(location: String, ships: ShipGroup):
    build_ships(location, ships)
    
func build_ships(location: String, ships: ShipGroup):
    var cost = ships.cost()
    player_materials -= cost["mats"]
    player_personnel -= cost["pers"]
    # Add ships
    for ship_type in ships.counts.keys():
        var count = ships.counts[ship_type]
        for i in count:
            all_ships.append({
                "type": ship_type,
                "location": location,
                "faction": "player"
            })
    map.update_gui()


func collect_resources():
    for star in map.system_map.values():
        if star.faction == "player":
            player_materials += star.materials
            player_supply += star.supply
            player_personnel += star.personnel


func end_combat(did_win: bool, survivors: ShipGroup):
    var move = current_move
    var from_star = map.system_map.get(move.from)
    var to_star = map.system_map.get(move.to)
    var attacker = from_star.faction
    var defender = to_star.faction
    if did_win:
        to_star.faction = "player"
        move.ships = survivors  # surviving attacker ships
        transfer_ships()
    else:
        to_star.faction = "ai"
        move.ships = ShipGroup.new()  # attacker lost, no survivors
        # defender keeps control, no ship transfer
    map.show()
    var combat_dialog = map.get_node("UI/CombatDialog")
    combat_dialog.show_result(did_win, survivors)
    combat_dialog.show()
    get_tree().get_root().get_node("Main/Battlefield").hide()
    map.update_gui()
    change_state(GameState.END_TURN)
