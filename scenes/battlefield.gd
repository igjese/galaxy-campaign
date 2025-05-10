extends Node2D

@onready var player_fleet = $PlayerFleet
@onready var ai_fleet = $AIFleet
@onready var ship_scene = preload("res://scenes/Ship.tscn")

func start():
    show()
    var move = GameLoop.current_move
    spawn_fleet(move.ships, player_fleet, false)
    spawn_fleet(move.ai_ships, ai_fleet, true)


func spawn_fleet(ship_group: ShipGroup, parent: Node, is_ai: bool):
    var x_base = (get_viewport_rect().size.x - 100) if is_ai else 100

    for ship_type in ship_group.counts.keys():
        var count = ship_group.counts[ship_type]
        for i in count:
            var ship = ship_scene.instantiate()
            ship.set_type(ship_type, is_ai)
            ship.position = get_random_spawn_position(x_base)
            ship.rotation_degrees = -90 if is_ai else 90
            ship.get_node("Hull").modulate = Color.LIGHT_CORAL if is_ai else Color.LIGHT_GREEN
            parent.add_child(ship)


func get_random_spawn_position(x_base: float) -> Vector2:
    var y_min = 100
    var y_max = get_viewport_rect().size.y - 100    
    var x_offset = randf_range(-50, 50)
    var y = randf_range(y_min, y_max)
    return Vector2(x_base + x_offset, y)
