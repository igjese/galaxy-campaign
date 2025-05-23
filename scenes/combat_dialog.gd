extends PopupPanel
class_name CombatDialog

var player_fleet = []
var ai_fleet = []
var location = ""


func open():
    var move = GameLoop.current_move
    $VBox/Title.text = "Battle at %s" % move.to
    $VBox/Result.text = "Battle is ready to start."
    
    var attacker = GameLoop.map.system_map.get(move.from).faction
    var player_fleet = move.ships if attacker == "player" else move.opponent
    var ai_fleet = move.opponent if attacker == "player" else move.ships

    populate_summary($VBox/Fleets/Player, player_fleet, "Player")
    populate_summary($VBox/Fleets/AI, ai_fleet, "AI")

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


func show_result(did_win: bool, survivors: ShipGroup):
    if did_win:
        $VBox/Result.text = "✔ Victory"
        $VBox/Fleets/Player.text = survivors.text("\n")
        $VBox/Fleets/AI.text = "None"
    else:
        $VBox/Result.text = "✘ Defeat"
        $VBox/Fleets/Player.text = "None"
        $VBox/Fleets/AI.text = "?"    
    $VBox/Buttons/StartBattle.visible = false
    $VBox/Buttons/Close.visible = true


func _on_close_pressed():
    hide()
    GameLoop.change_state(GameLoop.GameState.END_TURN)
