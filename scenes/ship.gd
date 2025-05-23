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
var laser_target_node: Node2D = null
var laser_timer: float = 0.0
var laser_duration: float = 0.2
var is_dying := false
var ship_name := ""
var names_human_1 = "res://assets/ships/naming/human1.txt"
var names_human_2 = "res://assets/ships/naming/human2.txt"
var names_alien_1 = "res://assets/ships/naming/alien1.txt"
var names_alien_2 = "res://assets/ships/naming/alien2.txt"


signal ship_destroyed(ship)
signal radio_chatter(ship, msg)

func _ready():
    flicker_offset = randf_range(0.0, TAU)  # Random phase offset


func set_type(ship_type: String, is_ai: bool):
    self.ship_type = ship_type
    self.is_ai = is_ai
    var design = GameData.ship_designs.get(ship_type, {})
    max_health = design.get("hp", 0)
    atk = design.get("atk", 0)
    def = design.get("def", 0)
    ship_name = generate_name()
    current_health = max_health
    var path = "res://assets/ships/%s.png" % ship_type
    $Hull.texture = load(path)
    var overlay = load("res://assets/ships/%s_overlay.png" % ship_type)
    $Damage.texture = overlay
    update_damage_overlay()
    scale_to_normalize()
    
    
func generate_name() -> String:
    var attr_path = names_alien_1 if is_ai else names_human_1
    var noun_path = names_alien_2 if is_ai else names_human_2
    var attrs = Helpers.load_array_from_file(attr_path)
    var nouns = Helpers.load_array_from_file(noun_path)
    var attr = attrs[randi() % attrs.size()]
    var noun = nouns[randi() % nouns.size()]
    return "%s %s" % [attr, noun]


func scale_to_normalize():
    var target_height = 30.0
    var current_height = $Hull.texture.get_height()
    var scale_factor = target_height / current_height * hull_scale[ship_type]
    scale = Vector2(scale_factor, scale_factor)


func _process(delta):
    if is_dying:
        return
    # flicker
    flicker_time += delta * 8.0  # Speed of flicker
    var flicker = 0.8 + 0.2 * sin(flicker_time + flicker_offset)  # Between 0.6 and 1.0
    $Exhaust.modulate = Color(flicker, flicker, flicker)
    $Exhaust.scale = Vector2(1, 1) * (0.9 + 0.1 * sin(flicker_time * 1.5 + flicker_offset))
    # laser
    if laser_timer > 0:
        laser_timer -= delta
        var pulse = 0.3 + 0.7 * sin(Time.get_ticks_msec() / 100.0)
        $Laser.modulate = Color(2.0, 0.4, 0.0, pulse)
        update_laser()
    else:
        $Laser.visible = false
        avoid_overlap()
        
func avoid_overlap():
    var my_pos = global_position
    for fleet in get_parent().get_parent().get_children():
        for other in fleet.get_children():
            if other == self:
                continue
            if other is Ship:
                var diff = my_pos - other.global_position
                var dist = diff.length()
                if dist < 30:  # adjust spacing threshold
                    global_position += diff.normalized() * 5 * get_process_delta_time()


func get_status() -> Dictionary:
    return {
        "health_ratio": clamp(float(current_health) / max_health, 0.0, 1.0),
    }
    
func get_ai() -> ShipAI:
    return $ShipAI  # or use `get_node("ShipAI")`


func fire_at(target: Node2D):
    laser_target_node = target
    laser_timer = laser_duration
    target.apply_base_damage(atk)

    
func draw_laser_to(hit_pos: Vector2):
    var laser = $Laser
    laser.clear_points()
    laser.add_point(Vector2.ZERO)
    laser.add_point(to_local(hit_pos))
    laser.visible = true
    await get_tree().create_timer(laser_duration).timeout
    laser.visible = false



func apply_base_damage(incoming: int):
    var effective_damage = max(incoming - def, 1)
    current_health -= effective_damage
    print("💢 %s takes %d damage (after %d def)" % [ship_name, effective_damage, def])
    spawn_explosion(0.5)
    update_damage_overlay()
    if current_health <= 0:
        die()

func die():
    if is_dying:
        return  # Prevent double-die bugs
    is_dying = true
    print("💥 %s destroyed!" % ship_name)
    emit_signal("radio_chatter", self, "Severely hit, abandoning ship.")
    emit_signal("ship_destroyed", self)
    spawn_explosion(1.5)
    await get_tree().create_timer(0.4).timeout
    queue_free()

    

func spawn_explosion(scale: float = 1.0):
    var explosion_size = 0.2 * scale * hull_scale[ship_type]
    var explosion = preload("res://scenes/Explosion.tscn").instantiate()
    explosion.scale = Vector2(explosion_size, explosion_size)
    explosion.global_position = global_position
    get_parent().add_child(explosion)


func update_laser():
    if not is_instance_valid(laser_target_node):
        $Laser.visible = false
        print("target not valid")
        return
    var laser = $Laser
    laser.clear_points()
    laser.add_point(Vector2.ZERO)
    laser.add_point(to_local(laser_target_node.global_position))
    laser.visible = true


func update_damage_overlay():
    var health_ratio = clamp(float(current_health) / max_health, 0.0, 1.0)
    var damage_intensity = sqrt(1.0 - health_ratio)  # nonlinear curve
    $Damage.modulate.a = damage_intensity
