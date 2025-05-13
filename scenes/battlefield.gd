extends Node2D

@onready var player_fleet = $PlayerFleet
@onready var ai_fleet = $AIFleet
@onready var player_admiral = $PlayerFleet/Admiral
@onready var ai_admiral = $AIFleet/Admiral
@onready var ship_scene = preload("res://scenes/Ship.tscn")

var player_ships := []
var ai_ships := []

enum Side { PLAYER, AI }

signal combat_complete(did_win: bool, survivors)

func start():
    show()
    var move = GameLoop.current_move
    spawn_fleet(move.ships, player_fleet, false)
    spawn_fleet(move.ai_ships, ai_fleet, true)
    player_admiral.assign_ships()
    ai_admiral.assign_ships()
    player_admiral.evaluate_battle()
    ai_admiral.evaluate_battle()
    player_ships = $PlayerFleet.get_children().filter(func(n): return n is Ship)
    ai_ships = $AIFleet.get_children().filter(func(n): return n is Ship)


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
            var ship_ai = ship.get_ai()
            if is_ai:
                ship_ai.side = Side.AI
                ship_ai.fleet = $AIFleet
                ship_ai.enemy_fleet = $PlayerFleet
            else:
                ship_ai.side = Side.PLAYER
                ship_ai.fleet = $PlayerFleet
                ship_ai.enemy_fleet = $AIFleet
            ship.connect("ship_destroyed", Callable(self, "_on_ship_destroyed"))


func get_random_spawn_position(x_base: float) -> Vector2:
    var y_min = 100
    var y_max = get_viewport_rect().size.y - 100    
    var x_offset = randf_range(-50, 50)
    var y = randf_range(y_min, y_max)
    return Vector2(x_base + x_offset, y)
    
    
func _on_ship_destroyed(ship):
    if player_ships.has(ship):
        player_ships.erase(ship)
    elif ai_ships.has(ship):
        ai_ships.erase(ship)

    if player_ships.is_empty():
        end_battle("ai")
    elif ai_ships.is_empty():
        end_battle("player")


func end_battle(winner: String):
    print("🏁 Battle ended — winner: %s" % winner)
    await get_tree().create_timer(1.5).timeout  # Add a 1-second pause
    var did_win = winner == "player" 
    # Transition out of combat here
    var survivors = collect_survivors(did_win)
    for ship in player_ships:
        if is_instance_valid(ship):
            ship.queue_free()
    for ship in ai_ships:
        if is_instance_valid(ship):
            ship.queue_free()   
    emit_signal("combat_complete", did_win, survivors)
    player_ships.clear()
    ai_ships.clear()

func collect_survivors(did_win) -> ShipGroup:
    if not did_win:
        return null
    var survivors := ShipGroup.new()
    var fleet_node = get_node("PlayerFleet")
    for ship in fleet_node.get_children():
        if ship is Ship:
            survivors.add_type(ship.ship_type, 1)
    return survivors
