extends HBoxContainer
class_name LineIncrement

signal count_changed(id: String, new_count: int)

var id := ""
var count := 0
var cost_mats := 0 # BUILD 
var cost_pers := 0 # BUILD 
var available := 0  # MOVE 

# modes must be same as in WorldDialog
enum Mode { BUILD, MOVE }
var current_mode = Mode.BUILD


func set_mode(mode: int):
    current_mode = mode
    update_gui()



func setup(line_id: String):
    id = line_id
    $LineName.text = id
    count = 0
    var design = GameData.ship_designs.get(id)
    cost_mats = design.cost_mats
    cost_pers = design.cost_pers
    update_gui()
    
func reset():
    count = 0
    update_gui()


func update_gui():
    $Qty.text = str(count)

    if current_mode == Mode.BUILD:  
        $Info.text = "Cost: %dM %dP" % [cost_mats * count, cost_pers * count]
    else:  # MOVE
        available = hulls_available(id)
        $Info.text = "%d available" % available

    emit_signal("count_changed", id, count)

func _on_decrease_pressed():
    if count > 0:
        count -= 1
        update_gui()

func _on_increase_pressed():
    count += 1
    update_gui()


func hulls_available(hull: String) -> int:
    var count = 0
    for ship in GameData.ships:
        if ship.faction == "player" and ship.location == GameData.selected_world.world_name and ship.type == hull:
            count += 1
    return count
