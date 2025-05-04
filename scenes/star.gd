extends Node2D

@export var world_name: String
@export var materials: int
@export var supply: int
@export var personnel: int
@export var faction: String = "ai"  # default to AI-owned
@export var has_shipyard: bool = false

@onready var name_label = $SystemNode/Name
@onready var info_label = $SystemNode/Info
@onready var texture_button = $SystemNode  # assuming SystemNode is the TextureButton
@onready var shipyard_icon = $SystemNode/Shipyard  # update path if needed

func _ready():
    update_labels()
    update_indicators()
    assign_random_texture()
    
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


func update_labels():
    name_label.text = world_name

    var info := ""
    if materials > 0:
        info += "M%d " % materials
    if supply > 0:
        info += "S%d " % supply
    if personnel > 0:
        info += "P%d" % personnel

    info_label.text = info
    
    var color = Color.LIGHT_GREEN if faction == "player" else Color.LIGHT_CORAL
    name_label.add_theme_color_override("font_color", color)
    info_label.add_theme_color_override("font_color", color)
