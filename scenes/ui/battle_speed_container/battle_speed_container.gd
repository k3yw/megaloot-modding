class_name BattleSpeedContainer extends MarginContainer




@export var margin_container: MarginContainer
@export var texture_rect: TextureRect
@export var label: GenericLabel


var target_brightness: float = 0.0
var curr_brightness: float = 0.0

var is_pressed: bool = false
var hovering: bool = false


var displayed_battle_speed: Options.BattleSpeed = Options.BattleSpeed.X2





func _process(delta: float) -> void :
    curr_brightness = lerp(curr_brightness, target_brightness, delta * 10.0)
    target_brightness = 0.0

    (texture_rect.material as ShaderMaterial).set_shader_parameter("brightness", curr_brightness)
    (label.material as ShaderMaterial).set_shader_parameter("brightness", curr_brightness)

    hovering = UI.is_hovered(margin_container)
    is_pressed = false


    if hovering:
        if Input.is_action_just_pressed("press"):
            is_pressed = true
        target_brightness = 0.75





func set_battle_speed(battle_speed: Options.BattleSpeed) -> void :
    var battle_speed_keys: Array = Options.BattleSpeed.keys()

    if not displayed_battle_speed == battle_speed:
        curr_brightness = -0.75

    label.text = battle_speed_keys[mini(battle_speed, battle_speed_keys.size() - 1)].to_lower()
    displayed_battle_speed = battle_speed
