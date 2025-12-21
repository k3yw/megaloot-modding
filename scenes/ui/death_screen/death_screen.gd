class_name DeathScreen extends SubViewportContainer

@export var animation_player: AnimationPlayer
@export var battle_log_button: GenericButton
@export var confirm_button: GenericButton
@export var main_container: MarginContainer

@export var death_floor_label: GenericLabel
@export var floor_record_label: GenericLabel

var shown: bool = false



func _ready() -> void :
    battle_log_button.pressed.connect( func(): PopupManager.pop(PopupManager.battle_log_popup_container))
    main_container.hide()




func animate_show() -> void :
    if shown:
        return

    main_container.show()
    animation_player.play("show")
    shown = true

    await animation_player.animation_finished


func set_death_floor(floor_number: int) -> void :
    death_floor_label.text = T.get_translated_string("died-on-floor").replace("{floor-number}", str(floor_number + 1))

func set_highest_floor(floor_number: int) -> void :
    floor_record_label.text = T.get_translated_string("highest-floor-result-screen").replace("{floor-number}", str(floor_number + 1))


func show_win_result(won: bool) -> void :
    death_floor_label.text = T.get_translated_string("Defeat")
    if won:
        death_floor_label.text = T.get_translated_string("Victory")
    floor_record_label.hide()

func show_final_floor() -> void :
    death_floor_label.text = T.get_translated_string("end-game-text")
    floor_record_label.hide()
