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


func _on_start_battle_pressed():
    var player_cost = Helpers.calculate_fleet_cost(player_fleet)
    var ai_cost = Helpers.calculate_fleet_cost(ai_fleet)
    var win_chance = float(player_cost) / (player_cost + ai_cost) * 1.2
    var did_win = randf() < win_chance
    var result_text := ""

    var lost_ships := {}

    if did_win:
        var loss_cost = int(ai_cost / 2.0)
        lost_ships = Helpers.calculate_loss_by_cost(player_fleet, loss_cost)
        var summary = Helpers.summarize_fleet(lost_ships)
        result_text = "✔ Victory!\nLost ships: %s" % (summary if summary != "" else "none")

    else:
        # Convert player_fleet array to a summary dict
        for ship in player_fleet:
            lost_ships[ship.type] = lost_ships.get(ship.type, 0) + 1
        result_text = "✘ Defeat!\nAll ships were destroyed."

    $VBox/Result.text = result_text
    $VBox/Buttons/StartBattle.visible = false
    $VBox/Buttons/Close.visible = true

    emit_signal("combat_complete", did_win, location, lost_ships)




func _on_close_pressed():
    hide()
