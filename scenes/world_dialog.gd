extends PopupPanel

@onready var line_container = $VBox/LineContainer
@onready var line_scene = preload("res://scenes/LineIncrement.tscn")

var world = null
var ship_order: ShipGroup

enum Mode { BUILD, MOVE }
var current_mode = Mode.BUILD

signal ships_built
signal move_queued(from: String, to: String, ships: ShipGroup)


func _ready():
    for hull in GameData.ship_designs.keys():
        var line = line_scene.instantiate()
        line.setup(hull)
        line.connect("count_changed", Callable(self, "_on_line_updated"))
        line_container.add_child(line)
        $VBox/Cmd/Move.get_popup().connect("id_pressed", Callable(self, "_on_move"))


func prepare_for_world(world_node):
    world = world_node
    ship_order = ShipGroup.new()
    $VBox/WorldName.text = "%s" % world_node.world_name

    var can_build = world.has_shipyard
    $VBox/Mode/Shipyard.visible = can_build
    
    # Default to MOVE mode if no shipyard
    current_mode = Mode.BUILD if can_build else Mode.MOVE
    switch_mode_for_lines()
    update_gui()
    popup_centered()


func _on_line_updated(id: String, count: int):
    ship_order.set_count(id, count)
    update_gui()


func update_gui():
    # Sync button state
    $VBox/Mode/Shipyard.button_pressed = (current_mode == Mode.BUILD)
    $VBox/Mode/Fleets.button_pressed = (current_mode == Mode.MOVE)

    # Calculate common info
    var total_ships = ship_order.total_count()
    var cost = ship_order.cost()
    
    # Toggle visibility
    $VBox/Cmd/Build.visible = (current_mode == Mode.BUILD)
    $VBox/Cmd/All.visible = (current_mode == Mode.MOVE)
    $VBox/Cmd/Move.visible = (current_mode == Mode.MOVE)

    if current_mode == Mode.BUILD:
        $VBox/Summary.text = "Total: %dM  %dP" % [cost["mats"], cost["pers"]]
        $VBox/Cmd/Build.disabled = (
            cost["mats"] > GameData.player_materials or
            cost["pers"] > GameData.player_personnel or
            total_ships == 0
        )
    elif current_mode == Mode.MOVE:
        $VBox/Summary.text = "Selected: %d ship(s)" % total_ships
        $VBox/Cmd/Move.disabled = (total_ships == 0)
        populate_move_destinations()


func _on_clear_pressed():
    clear_line_items()
    
    
func clear_line_items():
    ship_order.clear()
    for line in line_container.get_children():
        if line is LineIncrement:
            line.reset()
    update_gui()


func _on_build_pressed():
    # Calculate total cost using ShipGroup
    var cost = ship_order.cost()
    if GameData.player_materials < cost["mats"] or GameData.player_personnel < cost["pers"]:
        print("Not enough resources.")
        return

    # Deduct resources
    GameData.player_materials -= cost["mats"]
    GameData.player_personnel -= cost["pers"]

    # Create ships
    for type in ship_order.counts.keys():
        var count = ship_order.counts[type]
        for i in count:
            GameData.ships.append({
                "type": type,
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
