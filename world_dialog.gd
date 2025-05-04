extends PopupPanel

@onready var line_container = $VBox/LineContainer
@onready var line_scene = preload("res://scenes/LineIncrement.tscn")

var world = null
var ship_order = {}

enum Mode { BUILD, MOVE }
var current_mode = Mode.BUILD

signal ships_built
signal move_queued(from: String, to: String, ships: Dictionary)


func _ready():
    ship_order.clear()
    for hull in GameData.ship_designs.keys():
        var line = line_scene.instantiate()
        line.setup(hull)
        line.connect("count_changed", Callable(self, "_on_line_updated"))
        line_container.add_child(line)
        ship_order[hull] = 0
        $VBox/Cmd/Move.get_popup().connect("id_pressed", Callable(self, "_on_move"))


func prepare_for_world(world_node):
    world = world_node
    $VBox/WorldName.text = "%s" % world_node.world_name

    for line in line_container.get_children():
        line.reset()  # you'll add this method to set count = 0
        ship_order[line.id] = 0

    popup_centered()


func _on_line_updated(id: String, count: int):
    ship_order[id] = count
    update_gui()


func update_gui():
    # Sync button state
    $VBox/Mode/Shipyard.button_pressed = (current_mode == Mode.BUILD)
    $VBox/Mode/Fleets.button_pressed = (current_mode == Mode.MOVE)

    # Common UI logic
    var total_mats = 0
    var total_pers = 0
    var total_ships = 0

    for id in ship_order.keys():
        var count = ship_order[id]
        total_ships += count

        if current_mode == Mode.BUILD:
            var design = GameData.ship_designs.get(id)
            if design:
                total_mats += design.cost_mats * count
                total_pers += design.cost_pers * count
                
    $VBox/Cmd/Build.visible = (current_mode == Mode.BUILD)
    $VBox/Cmd/All.visible = (current_mode == Mode.MOVE)
    $VBox/Cmd/Move.visible = (current_mode == Mode.MOVE)

    if current_mode == Mode.BUILD:
        $VBox/Summary.text = "Total: %dM  %dP" % [total_mats, total_pers]
        $VBox/Cmd/Build.disabled = (
            total_mats > GameData.player_materials or
            total_pers > GameData.player_personnel or
            total_ships == 0
        )
    elif current_mode == Mode.MOVE:
        $VBox/Summary.text = "Selected: %d ship(s)" % total_ships
        $VBox/Cmd/Move.disabled = (total_ships == 0)
        populate_move_destinations()


func _on_clear_pressed():
    clear_line_items()
    
    
func clear_line_items():
    for line in line_container.get_children():
        if line is LineIncrement:
            line.reset()
            ship_order[line.id] = 0
    update_gui()


func _on_build_pressed():
    for id in ship_order.keys():
        var count = ship_order[id]
        if count == 0:
            continue

        var design = GameData.ship_designs.get(id)
        var cost_m = design.cost_mats * count
        var cost_p = design.cost_pers * count

        # Skip if insufficient resources
        if GameData.player_materials < cost_m or GameData.player_personnel < cost_p:
            print("Not enough resources to build %s" % id)
            continue

        # Deduct resources
        GameData.player_materials -= cost_m
        GameData.player_personnel -= cost_p

        # Create ship records
        for i in count:
            GameData.ships.append({
                "type": id,
                "location": world.world_name,
                "faction": "player"
            })

    hide()
    emit_signal("ships_built")


func _on_shipyard_pressed():
    current_mode = Mode.BUILD
    switch_mode_for_lines()
    update_gui()

    
func _on_fleets_pressed():
    current_mode = Mode.MOVE
    switch_mode_for_lines()
    update_gui()
    
func switch_mode_for_lines():
    clear_line_items()
    for line in line_container.get_children():
        if line is LineIncrement:
            line.set_mode(current_mode)
            
func _on_move(id: int):
    var destination = $VBox/Cmd/Move.get_popup().get_item_text(id)
    queue_move(destination)
    hide()
    
func queue_move(destination):
    # Queue each group of ships by type
    for ship_type in ship_order.keys():
        var count = ship_order[ship_type]
        if count == 0:
            continue

        GameData.pending_moves.append({
            "type": ship_type,
            "count": count,
            "from": world.world_name,
            "to": destination
        })

        # Remove moved ships from GameData.ships (real removal)
        var to_remove := []
        for ship in GameData.ships:
            if ship.faction == "player" and ship.location == world.world_name and ship.type == ship_type:
                to_remove.append(ship)
                if to_remove.size() == count:
                    break
        for ship in to_remove:
            GameData.ships.erase(ship)

    emit_signal("move_queued", world.world_name, destination, ship_order)



func populate_move_destinations():
    var menu = $VBox/Cmd/Move.get_popup()
    menu.clear()

    var index = 0
    for pair in GameData.connections:
        var other = ""
        if pair[0] == world.world_name:
            other = pair[1]
        elif pair[1] == world.world_name:
            other = pair[0]
        else:
            continue

        menu.add_item(other, index)
        index += 1


func _on_all_pressed():
    for line in line_container.get_children():
        if line is LineIncrement and current_mode == Mode.MOVE:
            line.count = line.available
            line.update_gui()
