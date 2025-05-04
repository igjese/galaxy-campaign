extends Node

var turn := 1
var player_materials := 0
var player_supply := 0
var player_personnel := 0


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
