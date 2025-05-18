extends Node

func calculate_fleet_cost(fleet: Array) -> int:
    var total = 0
    for ship in fleet:
        var design = GameData.ship_designs.get(ship.type)
        total += design.cost_mats + design.cost_pers
    return total


func calculate_loss_by_cost(fleet: Array, max_cost: int) -> Dictionary:
    var summary := {}
    var used = 0

    for ship in fleet:
        var cost = Helpers.cost_of(ship.type)
        if used + cost > max_cost:
            break
        used += cost
        summary[ship.type] = summary.get(ship.type, 0) + 1

    return summary


func summarize_fleet(fleet: Dictionary) -> String:
    var parts := []
    for type in fleet.keys():
        parts.append("%s:%d" % [type, fleet[type]])
    return ", ".join(parts)


func cost_of(type: String) -> int:
    var design = GameData.ship_designs.get(type)
    return design.cost_mats + design.cost_pers


func load_array_from_file(path: String) -> Array:
    var file = FileAccess.open(path, FileAccess.READ)
    if not file: 
        push_error("Failed to load file: %s" % path)
        return []
    var lines = []
    while not file.eof_reached():
        var line = file.get_line().strip_edges()
        if line != "":
            lines.append(line)
    return lines
