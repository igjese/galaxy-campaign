extends PopupPanel
class_name CombatDialog

signal combat_complete(did_win: bool, location: String, loss_cost: int)

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
    var text = "%s Fleet:\n" % faction
    for type in fleet.counts.keys():
        text += "%s x%d\n" % [type, fleet.counts[type]]
    label_node.text = text.strip_edges()


func _on_start_battle_pressed():
    GameLoop.resolve_battle()  # request logic

func show_result(result_text):
    $VBox/Result.text = result_text


func _on_close_pressed():
    hide()
