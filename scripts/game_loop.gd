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
    collect_resources()
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
    var star = map.system_map[current_move.to]
    if did_win:
        star.faction = "player"
        current_move.ships = survivors
        transfer_ships()
    else:
        # Player lost
        current_move.ships = ShipGroup.new()  # wiped out
    map.show()
    var combat_dialog = map.get_node("UI/CombatDialog")
    combat_dialog.show_result(did_win, survivors)
    combat_dialog.show()
    get_tree().get_root().get_node("Main/Battlefield").hide()
    map.update_gui()
    #change_state(GameState.END_TURN)
