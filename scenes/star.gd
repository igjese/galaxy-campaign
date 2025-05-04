extends Node2D

@export var world_name: String
@export var materials: int
@export var supply: int
@export var personnel: int
@export var faction: String = "ai"  # default to AI-owned
@export var has_shipyard: bool = false

var ships = {
    "FF": 0,
    "DD": 0
}


@onready var name_label = $SystemNode/Name
@onready var info_label = $SystemNode/Info
@onready var ships_label = $SystemNode/Ships
@onready var texture_button = $SystemNode  # assuming SystemNode is the TextureButton
@onready var shipyard_icon = $SystemNode/Shipyard  # update path if needed

func _ready():
    update_gui()
    update_indicators()
    assign_random_texture()
    $SystemNode.connect("pressed", Callable(self, "_on_system_pressed"))

func update_indicators():
    shipyard_icon.visible = has_shipyard
    var color = Color.LIGHT_GREEN if faction == "player" else Color.LIGHT_CORAL
    shipyard_icon.modulate = color

func assign_random_texture():
    var dir = DirAccess.open("res://assets/stars")
    if dir:
        var files = []
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.ends_with(".webp"):
                files.append("res://assets/stars/" + file_name)
            file_name = dir.get_next()
        dir.list_dir_end()

        if files.size() > 0:
            var selected = files[randi() % files.size()]
            texture_button.texture_normal = load(selected)

func update_gui():
    name_label.text = world_name

    var info := ""
    if materials > 0:
        info += "%dM " % materials
    if supply > 0:
        info += "%dS " % supply
    if personnel > 0:
        info += "%dP" % personnel

    info_label.text = info
    
    var ship_text := ""
    if faction == "player":
        var ship_counts := {}
        for ship in GameData.ships:
            if ship.location == world_name and ship.faction == "player":
                ship_counts[ship.type] = ship_counts.get(ship.type, 0) + 1

        for type in ship_counts.keys():
            ship_text += "%s:%d " % [type, ship_counts[type]]
    ships_label.text = ship_text
    
    var color = Color.LIGHT_GREEN if faction == "player" else Color.LIGHT_CORAL
    name_label.add_theme_color_override("font_color", color)
    info_label.add_theme_color_override("font_color", color)
    ships_label.add_theme_color_override("font_color", color)

    
func _on_system_pressed():
    if not has_shipyard:
        return
    GameData.open_build_dialog_for(self)
