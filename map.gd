extends Node2D 

@onready var connection_lines = $ConnectionLines
var system_map = {}

func _ready():
    # Build name → node map
    for node in get_children():
        if node.has_method("update_labels"):
            system_map[node.system_name] = node

    draw_connections()

func draw_connections():
    connection_lines.clear_points()

    for pair in GameData.connections:
        var name_a = pair[0]
        var name_b = pair[1]

        var pos_a = system_map[name_a].global_position
        var pos_b = system_map[name_b].global_position

        connection_lines.add_point(pos_a)
        connection_lines.add_point(pos_b)
        print(pos_a,pos_b)
