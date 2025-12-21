class_name BattleRoomActionContainer extends RoomActionContainer

@export var attack_stat_hover_info_module: HoverInfoModule
@export var attack_stat_container: StatContainer

@export var attack_button: GenericButton
@export var ability_button: GenericButton
@export var stance_button: GenericButton

@export var learned_ability_buttons: Array[GenericButton]


func _ready() -> void :
    attack_stat_hover_info_module.hover_info_name = T.get_translated_string("Attack Damage", "Keyword Name")
    attack_stat_hover_info_module.hover_info_name_color = Color.DARK_GRAY



func get_action_buttons() -> Array[GenericButton]:
    var action_buttons: Array[GenericButton] = [attack_button, ability_button, stance_button]
    for learned_ability_button in learned_ability_buttons:
        action_buttons.push_back(learned_ability_button)

    return action_buttons
