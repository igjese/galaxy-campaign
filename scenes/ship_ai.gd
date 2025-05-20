extends Node
class_name ShipAI

enum Side { PLAYER, AI }

var current_goal: String = ""
var goal_data: Dictionary = {}
var current_plan: String = ""
var steps: Array = []
var step_index := 0
var local_facts := {}
var sensor_range := 500.0
var weapon_range := 200.0
var side := Side.PLAYER  # or "ai"
var fleet: Node = null
var enemy_fleet: Node = null
var fire_order := false
var move_target: Node2D = null  # dynamic, tracks a node
var move_destination: Vector2 = Vector2.ZERO  # fixed point to move toward
var speed := 40.0
var drift_vector := Vector2.ZERO
var drift_speed := speed/15  # adjust for style
var stop_distance := 50.0
var last_action_issued: String = ""
var is_retreating := false
var captain_cooldown := 0.0
var captain_cooldown_max := 2.0  # Will be randomized
var captain_cooldown_interval := 0.5
var weapons_cooldown := 0.0
var weapons_cooldown_max := 3.0  # Will be randomized
var weapons_cooldown_interval := 0.5


func _process(delta):
    captain_cooldown -= delta
    if captain_cooldown <= 0.0:
        run_captain()
        captain_cooldown = randf_range(captain_cooldown_max - captain_cooldown_interval, captain_cooldown_max + captain_cooldown_interval)
    weapons_cooldown -= delta
    if weapons_cooldown <= 0.0:
        run_weapons()
        weapons_cooldown = randf_range(weapons_cooldown_max - weapons_cooldown_interval, weapons_cooldown_max + weapons_cooldown_interval)
    run_navigation(delta)
    
    
func move_toward_destination(target: Node2D):
    move_target = target
    if target:
        move_destination = target.global_position


func run_navigation(delta):
    var ship = get_parent()
    # If move_target is assigned, track its position continuously
    if move_target and is_instance_valid(move_target):
        move_destination = move_target.global_position
    # Move if we have a valid destination
    if move_destination != Vector2.ZERO:
        var distance = ship.global_position.distance_to(move_destination)
        if distance > stop_distance:
            var direction = (move_destination - ship.global_position).normalized()
            drift_vector = direction
            ship.global_position += direction * speed * delta
            rotate_ship_toward(direction, delta)
        else:
            move_target = null
            move_destination = Vector2.ZERO
    else:
        # Passive drift and idle rotation
        ship.global_position += drift_vector * drift_speed * delta
        var target_data = local_facts.get("closest_enemy", null)
        if target_data and target_data.has("ref"):
            var target = target_data["ref"]
            if is_instance_valid(target):
                var dir_to_target = (target.global_position - ship.global_position).normalized()
                rotate_ship_toward(dir_to_target, delta)



func rotate_ship_toward(direction: Vector2, delta: float):
    var ship = get_parent()
    if direction.length_squared() == 0:
        return
    var target_angle = direction.angle() + PI/2
    var rotate_speed = 2.0  # radians per second
    ship.rotation = lerp_angle(ship.rotation, target_angle, rotate_speed * delta)


func set_goal(goal_name: String):
    current_goal = goal_name
    for entry in GameLoop.goal_defs:
        if entry.has(goal_name):
            goal_data = entry[goal_name]
            break
    var plan = goal_data["plans"][0]  # First plan for now
    current_plan = plan.keys()[0]
    steps = plan[current_plan]["steps"]
    step_index = 0
    print("🧠 Goal set: %s → plan: %s → steps: %s" % [goal_name, current_plan, steps])


func run_weapons():
    if not fire_order:
        return
    gather_local_facts()
    var target_data = local_facts.get("closest_enemy", null)
    if target_data == null or not target_data.has("ref"):
        return
    var target = target_data["ref"]
    var dist = target_data["distance"]
    if dist > weapon_range:
        return  # Out of range
    print("🔫 [%s] Firing at %s (%.0f px)" % [get_parent().ship_name, target.ship_name, dist])
    get_parent().fire_at(target)
    

func run_captain():
    gather_local_facts()
    if local_facts.get("closest_enemy") == null:
        return  # No one left to act on
    if steps.is_empty():
        return
    var max_checks = steps.size()
    var issued = false
    while max_checks > 0 and not issued:
        var current_step = steps[step_index]
        if not is_step_active(current_step):
            run_step(current_step)
            print("[%s]: %s" % [get_parent(), current_step])
            issued = true  # stop after giving one new order
        else:
            step_index += 1
            if step_index >= steps.size():
                step_index = 0
                max_checks -= 1


func is_step_active(step: String) -> bool:
    if step == "fire_at_enemy":
        return fire_order
    if step == "move_toward_enemy":
        return move_target != null and not is_retreating
    if step == "run_away":
        return is_retreating and move_destination != Vector2.ZERO
    return false




func run_step(current_step):
    var ship = get_parent()
    if current_step == "fire_at_enemy":
        fire_order = true
        if current_step != last_action_issued:
            ship.emit_signal("radio_chatter", ship, "Weapons free.")
        print("[%s] %s: %s" % [ship.ship_type, ship.ship_name, "Weapons free."])
    elif current_step == "move_toward_enemy":
        if current_step != last_action_issued:
            ship.emit_signal("radio_chatter", ship, "Moving to engage.")
        print("[%s] %s: %s" % [ship.ship_type, ship.ship_name, "Moving to engage."])
        start_moving_toward_enemy()
    elif current_step == "run_away":
        ship.emit_signal("radio_chatter", ship, "Retreating.")
        print("[%s] %s: %s" % [ship.ship_type, ship.ship_name, "Retreating."])
        start_retreating()
    last_action_issued = current_step
    
    
func start_retreating():
    var retreat_point = Vector2(100, 400) if side == Side.PLAYER else Vector2(1100, 400)
    var dummy_node = Node2D.new()
    dummy_node.global_position = retreat_point
    move_toward_destination(dummy_node)
    is_retreating = true


func start_moving_toward_enemy():
    var target = local_facts.get("closest_enemy", {}).get("ref", null)
    if target:
        move_toward_destination(target)


    
func gather_local_facts():
    var ship := get_parent()
    local_facts = {}
    local_facts["ship_status"] = ship.get_status()
    # Find closest enemy
    var enemies = enemy_fleet.get_children().filter(func(c): return c is Ship)
    if enemies.is_empty():
        # No enemies left — exit safely
        local_facts["closest_enemy"] = null
        return
    var closest = null
    var closest_dist = INF
    for enemy in enemies:
        var dist = ship.global_position.distance_to(enemy.global_position)
        if dist < closest_dist:
            closest = enemy
            closest_dist = dist
    var dir = (closest.global_position - ship.global_position).normalized()
    local_facts["enemy_direction"] = dir

    local_facts["closest_enemy"] = {"ref": closest, "distance": closest_dist} if closest else null
    local_facts["doing"] = last_action_issued
    print(local_facts)


func get_battlefield() -> Node:
    return get_parent().get_parent()  # Assumes: ShipAI → Ship → Fleet → Battlefield
