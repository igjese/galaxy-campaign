extends Node
class_name Admiral

enum Side { PLAYER, AI }
var side: int = Side.PLAYER
var enemy: int = Side.AI
var ships: Array = []
var enemy_ships: Array = []
var doctrine: Dictionary = {}
var cooldown := 0.0
var cooldown_max := 5.0  # Will be randomized
var cooldown_interval := 1.0


func _ready():
    side = Side.PLAYER if "Player" in get_parent().name else Side.AI
    enemy = Side.AI if side == Side.PLAYER else Side.PLAYER
    load_doctrine()
    var label = "PLAYER" if side == Side.PLAYER else "AI"
    print("🫡 Admiral ready for %s fleet (%d ships)" % [label, ships.size()])


func _process(delta: float) -> void:
    if ships.is_empty():
        return  # Don’t evaluate before ships are assigned
    cooldown -= delta
    if cooldown <= 0.0:
        evaluate_battle()
        cooldown = randf_range(cooldown_max - cooldown_interval, cooldown_max + cooldown_interval)


func assign_ships():
    ships = get_ships_for(side)
    enemy_ships = get_ships_for(enemy)


func evaluate_battle():
    var facts = gather_facts()
    var roles = assign_roles(facts)
    assign_goals(roles)


func get_ships_for(which_side: int) -> Array:
    var fleet_name = "PlayerFleet" if which_side == Side.PLAYER else "AIFleet"
    var ships: Array = []
    var battlefield = get_parent().get_parent()
    if not battlefield.has_node(fleet_name):
        push_warning("⚠️ Fleet node '%s' not found under Battlefield" % fleet_name)
        return ships
    for item in battlefield.get_node(fleet_name).get_children():
        if item is Ship:
            ships.append(item)
    return ships


func load_doctrine():
    var file_path = "res://rules/doctrine.yaml"
    if not FileAccess.file_exists(file_path):
        push_warning("🧾 Doctrine file not found: " + file_path)
        return
    var parser = preload("res://scripts/yaml_parser.gd").new()
    doctrine = parser.load_yaml(file_path)
    print("📜 Doctrine loaded: ", doctrine)


func gather_facts() -> Dictionary:
    var facts = {}
    assign_ships()
    for ship in ships:
        facts[ship] = ship.get_status()
    return facts


func assign_roles(facts: Dictionary) -> Dictionary:
    var roles = {}
    var rules = doctrine.get("role_conditions", [])
    for ship in ships:
        var ship_facts = extract_ship_facts(ship, facts)
        var role = null
        for rule_entry in rules:
            for role_name in rule_entry.keys():
                var condition = rule_entry[role_name]
                if matches_condition(ship_facts, condition):
                    role = role_name
                    break
            if role != null:
                break
        if role == null:
            push_warning("🚨 No matching role found for ship: %s" % ship.name)
        roles[ship] = role
    return roles


func extract_ship_facts(ship, facts: Dictionary) -> Dictionary:
    var status = facts.get(ship, {})
    return {
        "health_ratio": status.get("health_ratio", 1.0)
    }



func matches_condition(ship_facts: Dictionary, condition: Dictionary) -> bool:
    if condition.has("health_below") and ship_facts["health_ratio"] < condition["health_below"]:
        return true
    if condition.has("default") and condition["default"]:
        return true
    return false



func assign_goals(roles: Dictionary):
    var preferences = doctrine.get("goal_preferences", {})
    for ship in roles.keys():
        var role = roles[ship]
        var goal = preferences.get(role, "seek_and_destroy")  # default fallback
        ship.get_ai().set_goal(goal)
        print("🎯 %s → role: %s → goal: %s" % [ship.ship_type, role, goal])
