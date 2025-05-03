extends Node2D

@onready var connection_lines = $ConnectionLines
@onready var star_scene = preload("res://scenes/Star.tscn")  # Adjust path as needed

var system_map = {}

func _ready():
    randomize()
    spawn_stars()
    draw_connections()

func spawn_stars():
    for name in GameData.systems.keys():
        var data = GameData.systems[name]

        var star = star_scene.instantiate()
        star.system_name = name
        star.materials = data.materials
        star.supply = data.supply
        star.personnel = data.personnel
        star.position = data.position
        star.faction = data.faction if data.has("faction") else "ai"

        add_child(star)
        system_map[name] = star

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
