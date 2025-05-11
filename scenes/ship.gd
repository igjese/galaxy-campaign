extends Node2D
class_name Ship

var ship_type := ""
var is_ai := false
var hull_scale = {"FF": 0.8, "DD": 1.2}

var flicker_offset := 0.0
var flicker_time := 0.0


func _ready():
    flicker_offset = randf_range(0.0, TAU)  # Random phase offset


func set_type(ship_type: String, is_ai: bool):
    self.ship_type = ship_type
    self.is_ai = is_ai
    var path = "res://assets/ships/%s.png" % ship_type
    var texture = load(path)
    $Hull.texture = texture
    scale_to_normalize()


func scale_to_normalize():
    var target_height = 30.0
    var current_height = $Hull.texture.get_height()
    var scale_factor = target_height / current_height * hull_scale[ship_type]
    scale = Vector2(scale_factor, scale_factor)


func _process(delta):
    flicker_time += delta * 8.0  # Speed of flicker
    var flicker = 0.8 + 0.2 * sin(flicker_time + flicker_offset)  # Between 0.6 and 1.0
    # Modulate brightness
    $Exhaust.modulate = Color(flicker, flicker, flicker)
    # Slight scale pulse
    $Exhaust.scale = Vector2(1, 1) * (0.9 + 0.1 * sin(flicker_time * 1.5 + flicker_offset))
