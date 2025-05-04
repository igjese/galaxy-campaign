extends PopupPanel

@onready var line_container = $VBox/LineContainer
@onready var line_scene = preload("res://scenes/LineIncrement.tscn")

var world = null
var build_order = {}

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
        line.reset_counts()  # you'll add this method to set count = 0
        build_order[line.id] = 0

    popup_centered()


func _on_line_updated(id: String, count: int):
    build_order[id] = count
