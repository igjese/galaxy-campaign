extends Node

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
    "FF": { "cost_mats": 2, "cost_pers": 0, "upkeep": 0, "hp": 20, "atk": 3, "def": 0 },
    "DD": { "cost_mats": 4, "cost_pers": 0, "upkeep": 0, "hp": 30, "atk": 5, "def": 1 }
}
