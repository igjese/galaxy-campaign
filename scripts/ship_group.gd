extends RefCounted
class_name ShipGroup

var counts: Dictionary = {}

func _init(data := {}):
    for ship_type in data.keys():
        counts[ship_type] = data[ship_type]


static func new_from_fleet(fleet: Array) -> ShipGroup:
    var group := ShipGroup.new()
    for ship in fleet:
        group.counts[ship.type] = group.counts.get(ship.type, 0) + 1
    return group


func text(separator: String = " ") -> String:
    if counts.is_empty():
        return ""
    var parts = []
    for type in counts.keys():
        if counts[type] > 0:
            parts.append("%s: %d" % [type, counts[type]])
    return separator.join(parts)


func cost() -> Dictionary:
    var mats := 0
    var pers := 0
    for type in counts:
        var design = GameData.ship_designs.get(type)
        mats += design.cost_mats * counts[type]
        pers += design.cost_pers * counts[type]
    return {
        "mats": mats,
        "pers": pers
    }


func set_count(type: String, count: int) -> void:
    counts[type] = count


func total_count() -> int:
    var total = 0
    for value in counts.values():
        total += value
    return total


func clear():
    counts.clear()


func subtract(other: ShipGroup):
    for type in other.counts.keys():
        var original = counts.get(type, 0)
        var to_remove = other.counts[type]
        var remaining = original - to_remove
        if remaining > 0:
            counts[type] = remaining
        else:
            counts.erase(type)


func duplicate() -> ShipGroup:
    var new_group := ShipGroup.new()
    for type in counts.keys():
        new_group.counts[type] = counts[type]
    return new_group


func add_type(type: String, amount: int = 1) -> void:
    counts[type] = counts.get(type, 0) + amount
