extends Node2D

@export var system_name: String
@export var materials: int
@export var supply: int
@export var personnel: int

@onready var name_label = $SystemNode/Name
@onready var info_label = $SystemNode/Info
@onready var texture_button = $SystemNode  # assuming SystemNode is the TextureButton

func _ready():
    update_labels()
    assign_random_texture()

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
    name_label.text = system_name

    var info := ""
    if materials > 0:
        info += "M%d " % materials
    if supply > 0:
        info += "S%d " % supply
    if personnel > 0:
        info += "P%d" % personnel

    info_label.text = info
