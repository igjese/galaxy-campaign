extends Node2D

@export var world_name: String
@export var materials: int
@export var supply: int
@export var personnel: int
@export var faction: String = "ai"  # default to AI-owned
@export var has_shipyard: bool = false

signal world_pressed(world_node)

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
    # world name
    name_label.text = world_name

    # world resources
    var info := ""
    if materials > 0:
        info += "%dM " % materials
    if supply > 0:
        info += "%dS " % supply
    if personnel > 0:
        info += "%dP" % personnel
    info_label.text = info
    
    # ships owned by player
    var ship_text := ""
    if faction == "player":
        var local_ships = GameData.ships.filter(
            func(s): return (s.location == world_name and s.faction == "player")
        )
        var group = ShipGroup.new_from_fleet(local_ships)
        ship_text = group.text()
    ships_label.text = ship_text
    
    # all info colored per faction
    var color = Color.LIGHT_GREEN if faction == "player" else Color.LIGHT_CORAL
    name_label.add_theme_color_override("font_color", color)
    info_label.add_theme_color_override("font_color", color)
    ships_label.add_theme_color_override("font_color", color)

    
func _on_system_pressed():
    emit_signal("world_pressed", self)
