extends Node2D

@onready var connection_lines = $ConnectionLines
@onready var world_scene = preload("res://scenes/Star.tscn")  # Adjust path as needed
@onready var move_indicator_scene = preload("res://scenes/MoveIndicator.tscn")

var system_map = {}


func _ready():
    seed(GameLoop.seed)
    spawn_worlds()
    draw_connections()
    connect_signals()
    update_gui()
    GameLoop.change_state(GameLoop.GameState.SETUP)

    
func connect_signals():
    $UI/WorldDialog.connect("move_queued", Callable(self, "_on_move_queued"))
    $UI/WorldDialog.connect("shipyard_order", Callable(GameLoop, "_on_shipyard_order"))
    get_parent().get_node("Battlefield").connect("combat_complete", Callable(self, "_on_combat_complete"))
    for world in system_map.values():
        world.connect("world_pressed", Callable(self, "_on_world_pressed"))


func spawn_worlds():
    for name in GameData.worlds.keys():
        var data = GameData.worlds[name]

        var world = world_scene.instantiate()
        world.world_name = name
        world.materials = data.materials
        world.supply = data.supply
        world.personnel = data.personnel
        world.position = data.position
        world.faction = data.faction if data.has("faction") else "ai"
        world.has_shipyard = data.has_shipyard if data.has("has_shipyard") else false
        world.connections = []  # 🔹 Add this line

        add_child(world)
        system_map[name] = world

    # Now populate connections after all worlds exist
    for pair in GameData.connections:
        var a = pair[0]
        var b = pair[1]
        if system_map.has(a):
            system_map[a].connections.append(b)
        if system_map.has(b):
            system_map[b].connections.append(a)



func draw_connections():
    connection_lines.clear_points()
    for pair in GameData.connections:
        var name_a = pair[0]
        var name_b = pair[1]
        if system_map.has(name_a) and system_map.has(name_b):
            var pos_a = system_map[name_a].global_position
            var pos_b = system_map[name_b].global_position
            connection_lines.add_point(pos_a)
            connection_lines.add_point(pos_b)


func _on_end_turn_pressed():
    GameLoop.change_state(GameLoop.GameState.END_TURN)
    
    
func update_gui():
    update_turn()
    update_resource_totals()
    update_worlds()
    

func update_worlds():
    for world in system_map.values():
        world.update_gui()

    
func update_turn():
    $UI/TurnCount.text = "Turn: %d" % GameLoop.turn
    
    
func update_resource_totals():
    $UI/Resources.text = "Materials: %d | Supply: %d | Personnel: %d" % [
        GameLoop.player_materials,
        GameLoop.player_supply,
        GameLoop.player_personnel
    ]


func _on_world_pressed(world_node):
    if world_node.faction != "player":
        return
    var has_ships = GameLoop.all_ships.any(func(s): return s.location == world_node.world_name and s.faction == "player")
    if world_node.has_shipyard or has_ships:
        GameLoop.selected_world = world_node
        $UI/WorldDialog.prepare_for_world(world_node)
        $UI/WorldDialog.popup_centered()


func _on_run_debug_pressed():
    var game = GameLoop
    game.run_debug = true
    var ships = ShipGroup.new({"FF":1,"DD":1})
    game.build_ships("Niraxis", ships)
    game.queue_move("Niraxis", "Velthara", ships, $Dummy)
    game.run_debug = false
    game.change_state(game.GameState.END_TURN)


func _on_combat_complete(did_win: bool, survivors: ShipGroup):
    GameLoop.end_combat(did_win, survivors)


func _on_move_queued(from: String, to: String, ships: ShipGroup):
    var indicator = create_move_indicator(from, to, ships.text())
    GameLoop.queue_move(from, to, ships, indicator)
    update_gui()


func create_move_indicator(from: String, to: String, label_text := "", color: Color = Color.LIGHT_GREEN) -> Node:
    var from_star = system_map.get(from)
    var to_star = system_map.get(to)
    var is_ai = (from_star.faction == "ai")
    
    if is_ai:
        label_text = "?"
        color = Color.LIGHT_CORAL
        
    var indicator = move_indicator_scene.instantiate()
    indicator.setup(from_star.global_position, to_star.global_position, label_text, color)
    $PendingMoves.add_child(indicator)
    return indicator
