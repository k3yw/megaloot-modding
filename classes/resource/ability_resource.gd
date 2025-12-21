class_name AbilityResource extends Resource



@export var name: String = ""
@export var icon: Texture2D = null

@export_range(0, 5) var mana_cost: int = 1
@export_range(-1, 10) var use_limit: int = 0


@export var status_effects_on_activation: Array[BonusStatusEffect] = []
@export var bonus_stats_while_active: Array[BonusStat] = []

@export var quick_cast: bool = false
@export var non_target: bool = true
@export var to_attack: bool = false


@export var ability_script: GDScript
@export var bb_script: GDScript






func get_preview_color() -> Color:
    if quick_cast:
        if use_limit:
            return Color("00e3c3")

        return Color("a7defa")

    return Color("5a8ef1")


func get_cast_color() -> Color:
    if use_limit:
        return Color("00c0b8")

    return Color("0076ff")
