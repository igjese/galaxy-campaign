extends Node

func calculate_fleet_cost(fleet: Array) -> int:
    var total = 0
    for ship in fleet:
        var design = GameData.ship_designs.get(ship.type)
        total += design.cost_mats + design.cost_pers
    return total
