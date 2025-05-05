extends PopupPanel
class_name CombatDialog

signal combat_complete(did_win: bool, location: String, loss_cost: int)

var player_fleet = []
var ai_fleet = []
var location = ""

func open(to: String, player: Array, ai: Array):
    player_fleet = player
    ai_fleet = ai
    location = to

    $VBox/Title.text = "Battle at %s" % to
    $VBox/Result.text = "Battle is ready to start."

    populate_summary($VBox/Fleets/Player, player_fleet, "Player")
    populate_summary($VBox/Fleets/AI, ai_fleet, "AI")

    $VBox/Buttons/StartBattle.visible = true
    $VBox/Buttons/Close.visible = false

    popup_centered()


func populate_summary(label_node: Label, fleet: Array, faction: String):
    var counts := {}
    for ship in fleet:
        counts[ship.type] = counts.get(ship.type, 0) + 1

    var text = "%s Fleet:\n" % faction
    for type in counts.keys():
        text += "%s x%d\n" % [type, counts[type]]
    label_node.text = text.strip_edges()


func _on_StartBattle_pressed():
    var player_cost = Helpers.calculate_fleet_cost(player_fleet)
    var ai_cost = Helpers.calculate_fleet_cost(ai_fleet)
    var win_chance = float(player_cost) / (player_cost + ai_cost)
    var did_win = randf() < win_chance
    var loss_cost = int(ai_cost / 2.0)

    var result_text := ""
    if did_win:
        result_text = "✔ Victory!\nLost %d cost worth of ships." % loss_cost
    else:
        result_text = "✘ Defeat!\nAll ships were destroyed."

    $VBox/Result.text = result_text

    # Hide battle button, show only Close
    $VBox/Buttons/StartBattle.visible = false
    $VBox/Buttons/Close.visible = true

    emit_signal("combat_complete", did_win, location, loss_cost)


func _on_Close_pressed():
    hide()
