extends Node2D

@onready var connection_lines = $ConnectionLines
@onready var world_scene = preload("res://scenes/Star.tscn")  # Adjust path as needed
@onready var move_indicator_scene = preload("res://scenes/MoveIndicator.tscn")

var system_map = {}


func _ready():
    seed(123)
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
        move.indicator.queue_free()
        var to_star = system_map.get(move.to)
        if to_star.faction == "ai":
            commence_battle(move)
        else:
            transfer_ships_to_destination(move)
            print("→ Moved to %s without combat" % move.to)
            
            
func commence_battle(move):
    var player_fleet = build_fleet("player", move.to, move.type, move.count)
    GameData.ships += player_fleet

    var player_cost = Helpers.calculate_fleet_cost(player_fleet)
    var ai_fleet = generate_ai_fleet(player_cost)

    var combat_dialog = $UI/CombatDialog
    combat_dialog.open(move.to, player_fleet, ai_fleet)


func show_combat_dialog(from, to, player_fleet, ai_fleet):
    var player_cost = Helpers.calculate_fleet_cost(player_fleet)
    var ai_cost = Helpers.calculate_fleet_cost(ai_fleet)

    var win_chance = float(player_cost) / (player_cost + ai_cost)
    var did_win = randf() < win_chance

    if did_win:
        apply_victory(to, ai_cost / 2.0)
    else:
        apply_defeat(to)


func apply_victory(to: String, loss_cost: float):
    var star = system_map[to]
    star.faction = "player"
    trim_ships(to, int(loss_cost))
    star.update_gui()
    print("✔ Victory at %s!" % to)


func apply_defeat(to: String):
    GameData.ships = GameData.ships.filter(func(ship):
        return not (ship.faction == "player" and ship.location == to)
    )
    print("✘ Defeat at %s! All ships lost." % to)
    
    
func transfer_ships_to_destination(move):
    var new_ships = build_fleet("player", move.to, move.type, move.count)
    GameData.ships += new_ships


func build_fleet(faction: String, location: String, ship_type: String, count: int) -> Array:
    var result = []
    for i in count:
        result.append({
            "type": ship_type,
            "faction": faction,
            "location": location
        })
    return result


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
