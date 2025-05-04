extends Node

var turn := 1
var player_materials := 10
var player_supply := 10
var player_personnel := 10

var selected_world = null

var ships = []  # each ship is a dict or lightweight object


func open_build_dialog_for(world_node):
    selected_world = world_node
    var dialog = get_tree().get_root().get_node("Map/UI/BuildDialog")
    dialog.popup_centered()
    dialog.prepare_for_world(world_node)


var worlds = {
    "Velthara": {
        "position": Vector2(200, 400),
        "materials": 3,
        "supply": 2,
        "personnel": 1
    },
    "Niraxis": {
        "position": Vector2(420, 320),
        "materials": 5,
        "supply": 5,
        "personnel": 5,
        "faction": "player",
        "has_shipyard": true
    },
    "Tessilune": {
        "position": Vector2(600, 380),
        "materials": 2,
        "supply": 1,
        "personnel": 0
    },
    "Corvyn": {
        "position": Vector2(780, 200),
        "materials": 0,
        "supply": 3,
        "personnel": 2
    },
    "Zharan": {
        "position": Vector2(650, 550),
        "materials": 4,
        "supply": 1,
        "personnel": 1
    },
    "Elydris": {
        "position": Vector2(940, 600),
        "materials": 1,
        "supply": 2,
        "personnel": 3
    }
}

var connections = [
    ["Velthara", "Niraxis"],
    ["Niraxis", "Tessilune"],
    ["Tessilune", "Corvyn"],
    ["Tessilune", "Zharan"],
    ["Elydris", "Corvyn"],
    ["Elydris", "Zharan"]
]

var ship_designs = {
    "FF": { "cost_mats": 3, "cost_pers": 2, "upkeep": 1, "hp": 10, "atk": 5, "def": 2 },
    "DD": { "cost_mats": 5, "cost_pers": 3, "upkeep": 2, "hp": 20, "atk": 8, "def": 4 }
}
