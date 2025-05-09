extends Node2D

@onready var connection_lines = $ConnectionLines
@onready var world_scene = preload("res://scenes/Star.tscn")  # Adjust path as needed
@onready var move_indicator_scene = preload("res://scenes/MoveIndicator.tscn")

var system_map = {}
var current_battle_move = null



func _ready():
    seed(1234)
    spawn_worlds()
    draw_connections()
    connect_signals()
    update_gui()
    GameLoop.change_state(GameLoop.GameState.SETUP)

    
func connect_signals():
    $UI/WorldDialog.connect("ships_built", Callable(self, "update_gui"))
    $UI/WorldDialog.connect("move_queued", Callable(self, "_on_move_queued"))
    $UI/CombatDialog.connect("combat_complete", Callable(self, "_on_combat_complete"))
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

        add_child(world)
        system_map[name] = world


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
    
    
func collect_resources():
    for star in system_map.values():
        if star.faction == "player":
            GameLoop.player_materials += star.materials
            GameLoop.player_supply += star.supply
            GameLoop.player_personnel += star.personnel
    
    
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


func _on_move_queued(from: String, to: String, ships: ShipGroup):
    var from_star = system_map.get(from)
    var to_star = system_map.get(to)
    var indicator = move_indicator_scene.instantiate()
    indicator.setup(from_star.global_position, to_star.global_position, ships.text())
    $PendingMoves.add_child(indicator)
    GameLoop.queue_move(from, to, ships, indicator)
    update_gui()


func open_build_dialog_for(world_node):
    GameLoop.selected_world = world_node
    var dialog = get_tree().get_root().get_node("Map/UI/WorldDialog")
    dialog.popup_centered()
    dialog.prepare_for_world(world_node)


func _on_world_pressed(world_node):
    if world_node.faction != "player":
        return
    var has_ships = GameLoop.all_ships.any(func(s): return s.location == world_node.world_name and s.faction == "player")
    if world_node.has_shipyard or has_ships:
        GameLoop.selected_world = world_node
        $UI/WorldDialog.prepare_for_world(world_node)
        $UI/WorldDialog.popup_centered()
