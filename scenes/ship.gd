extends Node2D
class_name Ship

var ship_type := ""
var is_ai := false
var hull_scale = {"FF": 0.8, "DD": 1.2}
var flicker_offset := 0.0
var flicker_time := 0.0
var current_health := 0
var max_health := 0
var atk := 0
var def := 0

func _ready():
    flicker_offset = randf_range(0.0, TAU)  # Random phase offset


func set_type(ship_type: String, is_ai: bool):
    self.ship_type = ship_type
    self.is_ai = is_ai
    var design = GameData.ship_designs.get(ship_type, {})
    max_health = design.get("hp", 0)
    atk = design.get("atk", 0)
    def = design.get("def", 0)
    current_health = max_health
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


func get_status() -> Dictionary:
    return {
        "health_ratio": clamp(current_health / max_health, 0.0, 1.0),
    }
    
func get_ai() -> ShipAI:
    return $ShipAI  # or use `get_node("ShipAI")`


func fire_at(target: Node2D):
    draw_laser_to(target)
    target.apply_base_damage(atk)  # or whatever amount

    
func draw_laser_to(target):
    var laser = $Laser
    laser.clear_points()
    laser.add_point(Vector2.ZERO)  # From self
    laser.add_point(to_local(target.global_position))  # To target
    laser.visible = true
    # Hide after delay
    await get_tree().create_timer(0.2).timeout
    laser.visible = false


func apply_base_damage(incoming: int):
    var effective_damage = max(incoming - def, 1)
    current_health -= effective_damage
    print("💢 %s takes %d damage (after %d def)" % [name, effective_damage, def])
    
    if current_health <= 0:
        die()

func die():
    print("💥 %s destroyed!" % name)
    queue_free()
