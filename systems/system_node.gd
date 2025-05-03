extends TextureButton

@export var system_name: String = "Unnamed System"
@export var owned_by: String = "Neutral"
@export var materials: int = 0
@export var supply: int = 0
@export var personnel: int = 0

@onready var name_label = $Name
@onready var info_label = $Info

func _ready():
    update_labels()

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
    
