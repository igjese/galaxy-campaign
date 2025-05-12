extends PopupPanel
class_name CombatDialog

var player_fleet = []
var ai_fleet = []
var location = ""


func open():
    var move = GameLoop.current_move
    $VBox/Title.text = "Battle at %s" % move.to
    $VBox/Result.text = "Battle is ready to start."

    populate_summary($VBox/Fleets/Player, move.ships, "Player")
    populate_summary($VBox/Fleets/AI, move.ai_ships, "AI")

    $VBox/Buttons/StartBattle.visible = true
    $VBox/Buttons/Close.visible = false
    popup_centered()


func populate_summary(label_node: Label, fleet: ShipGroup, faction: String):
    label_node.text = "%s Fleet:\n%s" % [faction, fleet.text("\n")]


func _on_start_battle_pressed():
    #GameLoop.resolve_battle()  # request logic
    hide()
    get_tree().get_root().get_node("Main/Map").hide()
    var battlefield = get_tree().get_root().get_node("Main/Battlefield")
    battlefield.start()


func show_result(result_text):
    $VBox/Result.text = result_text
    $VBox/Buttons/StartBattle.visible = false
    $VBox/Buttons/Close.visible = true


func _on_close_pressed():
    hide()
