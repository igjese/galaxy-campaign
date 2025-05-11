extends Node
class_name Admiral

enum Side { PLAYER, AI }

var side: int = Side.PLAYER
var enemy: int = Side.AI

var ships: Array = []
var enemy_ships: Array = []

var doctrine: Dictionary = {}


func _ready():
    # Determine which side this admiral belongs to
    side = Side.PLAYER if "Player" in get_parent().name else Side.AI
    enemy = Side.AI if side == Side.PLAYER else Side.PLAYER
    
    load_doctrine()

    var label = "PLAYER" if side == Side.PLAYER else "AI"
    print("🫡 Admiral ready for %s fleet (%d ships)" % [label, ships.size()])


func assign_ships():
    ships = get_ships_for(side)
    enemy_ships = get_ships_for(enemy)



func evaluate_battle():
    for ship in ships:
        assign_goal(ship)


func assign_goal(ship):
    var preferred = null

    if ship.health_ratio < 0.3:
        preferred = doctrine.get("goal_preferences", {}).get("damaged", null)
    elif ship.role in doctrine.get("goal_preferences", {}):
        preferred = doctrine["goal_preferences"][ship.role]

    if preferred == null:
        preferred = "seek_and_destroy"  # default fallback

    ship.override_goal = preferred
    print("🎯 Assigned goal to %s: %s" % [ship.name, preferred])


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
