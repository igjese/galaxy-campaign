extends Node2D

var ship_type := ""
var is_ai := false
var hull_scale = {"FF": 0.8, "DD": 1.2}


func set_type(ship_type: String, is_ai: bool):
    self.ship_type = ship_type
    self.is_ai = is_ai
    var path = "res://assets/ships/%s.png" % ship_type
    var texture = load(path)
    $Ship.texture = texture
    scale_to_normalize()


func scale_to_normalize():
    var target_height = 30.0
    var current_height = $Ship.texture.get_height()
    var scale_factor = target_height / current_height * hull_scale[ship_type]
    scale = Vector2(scale_factor, scale_factor)
