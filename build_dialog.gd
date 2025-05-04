extends PopupPanel

@onready var line_container = $VBox/LineContainer
@onready var line_scene = preload("res://scenes/LineIncrement.tscn")

var world = null
var build_order = {}

signal ships_built


func _ready():
    build_order.clear()
    for hull in GameData.ship_designs.keys():
        var line = line_scene.instantiate()
        line.setup(hull)
        line.connect("count_changed", Callable(self, "_on_line_updated"))
        line_container.add_child(line)
        build_order[hull] = 0


func prepare_for_world(world_node):
    world = world_node
    $VBox/Shipyard.text = "%s shipyards" % world_node.world_name

    for line in line_container.get_children():
        line.reset()  # you'll add this method to set count = 0
        build_order[line.id] = 0

    popup_centered()


func _on_line_updated(id: String, count: int):
    build_order[id] = count
    update_total_cost()


func update_total_cost():
    var total_mats = 0
    var total_pers = 0

    for id in build_order.keys():
        var count = build_order[id]
        var design = GameData.ship_designs.get(id)
        if design:
            total_mats += design.cost_mats * count
            total_pers += design.cost_pers * count

    $VBox/Total.text = "Total: %dM  %dP" % [total_mats, total_pers]

    $VBox/Cmd/Build.disabled = (
        total_mats > GameData.player_materials or
        total_pers > GameData.player_personnel
    )    


func _on_clear_pressed():
    for line in line_container.get_children():
        if line is LineIncrement:
            line.reset()
            build_order[line.id] = 0
    update_total_cost()


func _on_build_pressed():
    for id in build_order.keys():
        var count = build_order[id]
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
