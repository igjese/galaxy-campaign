extends Node2D

@onready var connection_lines = $ConnectionLines
@onready var world_scene = preload("res://scenes/Star.tscn")  # Adjust path as needed

var system_map = {}


func _ready():
    randomize()
    spawn_worlds()
    draw_connections()
    connect_signals()
    update_gui()
    
    
func connect_signals():
    $UI/BuildDialog.connect("ships_built", Callable(self, "update_gui"))


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
    end_turn()


func end_turn():
    GameData.turn += 1
    collect_resources()
    update_gui()
    
    
func collect_resources():
    for star in system_map.values():
        if star.faction == "player":
            GameData.player_materials += star.materials
            GameData.player_supply += star.supply
            GameData.player_personnel += star.personnel
    
    
func update_gui():
    update_turn()
    update_resource_totals()
    update_worlds()
    

func update_worlds():
    for world in system_map.values():
        world.update_gui()

    
func update_turn():
    $UI/TurnCount.text = "Turn: %d" % GameData.turn
    
    
func update_resource_totals():
    $UI/Resources.text = "Materials: %d | Supply: %d | Personnel: %d" % [
        GameData.player_materials,
        GameData.player_supply,
        GameData.player_personnel
    ]
