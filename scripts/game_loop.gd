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

var selected_world = null
var all_ships = []  # each ship is a dict or lightweight object


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
    map = get_tree().get_root().get_node("Map")
    combat_dialog = map.get_node("UI/CombatDialog")


func begin_start_turn():
    turn += 1
    map.collect_resources()
    map.update_gui()
    change_state(GameState.IDLE)
    
    
func begin_end_turn():
    if not pending_moves.is_empty():
        change_state(GameState.PROCESS_MOVES)
    else:
        change_state(GameState.START_TURN)
        

func begin_process_moves():
    current_move = pending_moves.pop_front()
    current_move.indicator.queue_free()
    var to_star = map.system_map.get(current_move.to)
    if to_star.faction == "ai":
        change_state(GameState.COMBAT)
    else:
        change_state(GameState.MOVE)
        
        
func begin_move():
    map.transfer_ships()
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
    var player_fleet = current_move.ships
    var player_cost = player_fleet.cost()["mats"] + player_fleet.cost()["pers"]

    current_move.ai_ships = generate_ai_fleet(player_cost)  # Returns ShipGroup
    combat_dialog.open()


func generate_ai_fleet(max_cost: int) -> ShipGroup:
    var result := ShipGroup.new()
    var types = GameData.ship_designs.keys()
    while max_cost > 0:
        var type = types[randi() % types.size()]
        var design = GameData.ship_designs[type]
        var cost = design.cost_mats + design.cost_pers
        if cost <= max_cost:
            result.counts[type] = result.counts.get(type, 0) + 1
            max_cost -= cost
        else:
            break
    return result
    
    
func resolve_battle():
    var outcome = simulate_battle()
    process_battle_results(outcome)


func simulate_battle():
    var player_fleet = current_move.ships
    var ai_fleet = current_move.ai_ships
    var player_cost = player_fleet.cost()
    var ai_cost = ai_fleet.cost()
    var win_chance = float(player_cost["mats"] + player_cost["pers"]) / (player_cost["mats"] + player_cost["pers"] + ai_cost["mats"] + ai_cost["pers"])
    var roll = randf()
    var did_win = roll < win_chance
    var result_text := ""
    var lost_ships := ShipGroup.new()
    if did_win:
        var loss_cost = int(ai_cost["mats"] + ai_cost["pers"]) / 2
        lost_ships = calculate_losses(loss_cost)
        result_text = "✔ Victory!\nLost ships: %s" % lost_ships.text()
    else:
        lost_ships = player_fleet
        result_text = "✘ Defeat!\nAll ships were destroyed."
    return { "did_win": did_win, "lost_ships": lost_ships }


func calculate_losses(max_loss_cost: int) -> ShipGroup:
    var lost := ShipGroup.new()
    var total_lost_cost := 0
    var sorted_types = current_move.ships.counts.keys()
    sorted_types.sort_custom(func(a, b):
        var ca = GameData.ship_designs[a].cost_mats + GameData.ship_designs[a].cost_pers
        var cb = GameData.ship_designs[b].cost_mats + GameData.ship_designs[b].cost_pers
        return cb - ca  # higher-cost ships lost first
    )
    for ship_type in sorted_types:
        var design = GameData.ship_designs[ship_type]
        var unit_cost = design.cost_mats + design.cost_pers
        var available = current_move.ships.counts[ship_type]
        for i in available:
            if total_lost_cost + unit_cost > max_loss_cost:
                return lost
            lost.add_type(ship_type, 1)
            total_lost_cost += unit_cost
    return lost


func process_battle_results(outcome):
    var star = map.system_map[current_move.to]
    var outcome_msg = ""
    if outcome.did_win:
        star.faction = "player"
        outcome_msg = "✔ Victory!\nLost ships: %s" % outcome.lost_ships.text()
        current_move.ships.subtract(outcome.lost_ships)
        transfer_ships()
    else:
        outcome_msg = "✘ Defeat!\nAll ships were destroyed."
    print("Battle at %s: %s" % [star,outcome_msg])
    combat_dialog.show_result(outcome_msg)    
    map.update_gui()
    change_state(GameState.END_TURN)


func queue_move(from: String, to: String, ships: ShipGroup, indicator: Node):
    # Add move to internal queue
    pending_moves.append({
        "from": from,
        "to": to,
        "ships": ships,
        "indicator": indicator
    })
    # Remove moved ships from GameLoop.ships (actual game state mutation)
    var remaining := []
    var pending_counts := ships.counts.duplicate()
    for ship in all_ships:
        if ship.faction == "player" and ship.location == from:
            var t = ship.type
            if pending_counts.has(t) and pending_counts[t] > 0:
                pending_counts[t] -= 1
                continue  # ship is in transit
        remaining.append(ship)
    all_ships = remaining
