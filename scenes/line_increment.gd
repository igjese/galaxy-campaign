extends HBoxContainer
class_name LineIncrement

signal count_changed(id: String, new_count: int)

var id := ""
var count := 0

func setup(line_id: String):
    id = line_id
    $LineName.text = id
    count = 0
    update_count()
    
func reset_counts():
    count = 0
    update_count()


func update_count():
    $Qty.text = str(count)
    emit_signal("count_changed", id, count)

func _on_decrease_pressed():
    if count > 0:
        count -= 1
        update_count()

func _on_increase_pressed():
    count += 1
    update_count()
