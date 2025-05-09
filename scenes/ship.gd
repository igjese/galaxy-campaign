extends Node2D

var ship_type := ""
var is_ai := false

@onready var ship_sprite = $Ship  # or whatever path


func _ready():
    scale_to_normalize()
    
    
func scale_to_normalize():
    var target_height = 30.0
    var current_height = ship_sprite.texture.get_height()
    var scale_factor = target_height / current_height
    scale = Vector2(scale_factor, scale_factor)


func set_type(ship_type: String, is_ai: bool):
    self.ship_type = ship_type
    self.is_ai = is_ai
    # Set sprite, stats, etc.
