extends Node2D

@onready var connection_lines = $ConnectionLines
@onready var world_scene = preload("res://scenes/Star.tscn")  # Adjust path as needed
@onready var move_indicator_scene = preload("res://scenes/MoveIndicator.tscn")

var system_map = {}


func _ready():
    randomize()
    spawn_worlds()
    draw_connections()
    connect_signals()
    update_gui()
    
    
func connect_signals():
    $UI/WorldDialog.connect("ships_built", Callable(self, "update_gui"))
    $UI/WorldDialog.connect("move_queued", Callable(self, "_on_move_queued"))


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
    resolve_pending_moves()
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

func _on_move_queued(from: String, to: String, ships: Dictionary):
    var from_star = system_map.get(from)
    var to_star = system_map.get(to)

    var label = ""
    for type in ships.keys():
        var count = ships[type]
        if count > 0:
            label += "%s:%d  " % [type, count]

    var indicator = move_indicator_scene.instantiate()
    indicator.setup(from_star.global_position, to_star.global_position, label.strip_edges())
    $PendingMoves.add_child(indicator)
        
    # Queue each group of ships by type
    for ship_type in ships.keys():
        var count = ships[ship_type]
        if count == 0:
            continue

        GameData.pending_moves.append({
            "type": ship_type,
            "count": count,
            "from": from,
            "to": to,
            "indicator": indicator
        })

        # Remove moved ships from GameData.ships (real removal)
        var to_remove := []
        for ship in GameData.ships:
            if ship.faction == "player" and ship.location == from and ship.type == ship_type:
                to_remove.append(ship)
                if to_remove.size() == count:
                    break
        for ship in to_remove:
            GameData.ships.erase(ship)
    update_gui()

func resolve_pending_moves():
    while GameData.pending_moves.size() > 0:
        var move = GameData.pending_moves.pop_front()

        var from = move.from
        var to = move.to
        var ship_type = move.type
        var count = move.count
        var indicator = move.indicator

        var to_world = system_map.get(to)

        # Recreate player ships at destination
        var player_ships = []
        var player_cost = 0

        for i in range(count):
            var ship = {
                "type": ship_type,
                "faction": "player",
                "location": to
            }
            player_ships.append(ship)
            var design = GameData.ship_designs.get(ship_type)
            player_cost += design.cost_mats + design.cost_pers

        GameData.ships += player_ships

        if to_world.faction == "ai":
            var ai_fleet = generate_ai_fleet(player_cost)
            var ai_cost = calculate_fleet_cost(ai_fleet)
            var win_chance = float(player_cost) / (player_cost + ai_cost)

            if randf() < win_chance:
                to_world.faction = "player"
                trim_ships(to, int(ai_cost / 2.0))
                to_world.update_gui()
                print("✔ Victory at %s! (Lost %d cost worth of ships)" % [to, int(ai_cost / 2.0)])
            else:
                GameData.ships = GameData.ships.filter(func(ship):
                    return not (ship.faction == "player" and ship.location == to)
                )
                print("✘ Defeat at %s! All ships lost." % to)
        else:
            print("→ Moved to %s without combat" % to)
        move.indicator.queue_free()


func calculate_fleet_cost(fleet: Array) -> int:
    var total = 0
    for ship in fleet:
        var design = GameData.ship_designs.get(ship.type)
        total += design.cost_mats + design.cost_pers
    return total


func generate_ai_fleet(max_cost: int) -> Array:
    var fleet = []
    var types = GameData.ship_designs.keys()
    while max_cost > 0:
        var type = types[randi() % types.size()]
        var design = GameData.ship_designs.get(type)
        var cost = design.cost_mats + design.cost_pers
        if cost <= max_cost:
            fleet.append({ "type": type })
            max_cost -= cost
        else:
            break
    return fleet


func trim_ships(location: String, loss_cost: int):
    var removed_cost = 0
    var survivors = []

    for ship in GameData.ships:
        if ship.faction == "player" and ship.location == location and removed_cost < loss_cost:
            var design = GameData.ship_designs.get(ship.type)
            removed_cost += design.cost_mats + design.cost_pers
            continue  # skip adding this ship
        survivors.append(ship)

    GameData.ships = survivors
