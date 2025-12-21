@tool
class_name ResourceBar extends MarginContainer


@export var back_panel: Panel

@export var effect_container_holder: EffectContainerHolder

@export var max_amount_label: GenericLabel
@export var amount_label: GenericLabel
@export var misc_label: GenericLabel

@export var progress_bar_under: ProgressBar
@export var progress_bar_main: ProgressBar
@export var progress_bar_over: ProgressBar


@onready var target_value_under: float = progress_bar_main.value
@onready var target_value: float = progress_bar_main.value
@onready var target_value_over: float = progress_bar_over.value

@export var label_margin_container: MarginContainer
@export var debuffs_container: MarginContainer
@export var label_container: HBoxContainer


var progress_bar_under_cooldown: float





func update_as_health(character: Character) -> void :
    var max_health: float = character.get_max_health()
    var overhealed: bool = character.is_overhealed()
    var health: float = character.get_health()
    var color: Color = Color("#9e1a3c")

    max_amount_label.target_value = max_health
    amount_label.target_value = health

    max_amount_label.is_value = not overhealed
    amount_label.visible = not overhealed
    misc_label.visible = not overhealed

    if overhealed:
        max_amount_label.text = Format.number(roundf(health), max_amount_label.get_rules())
        max_amount_label.curr_value = 0

    set_max_value(max_health)
    set_target_value(health)
    set_target_value_under(health)

    if overhealed:
        color = Color("#ff4d85")



    set_color(color)





func set_color(color: Color) -> void :
    max_amount_label.set_text_color(0, color)
    amount_label.set_text_color(0, color)
    misc_label.set_text_color(0, color)
    progress_bar_main.modulate = color
    back_panel.modulate = color





func _notification(what: int) -> void :
    if Engine.is_editor_hint():
        return

    match what:
        NOTIFICATION_SORT_CHILDREN:
            process_label_position()




func set_max_value(amount: float) -> void :
    amount = max(0, amount)

    if not progress_bar_main.max_value == amount:
        progress_bar_main.max_value = amount
        progress_bar_main.value = amount

    if not progress_bar_under.max_value == amount:
        progress_bar_under.max_value = amount
        progress_bar_under.value = amount








func set_target_value_under(amount: float) -> void :
    amount = max(0, amount)

    if target_value_under == amount:
        return

    if amount > target_value_under:
        progress_bar_under.value = amount

    progress_bar_under_cooldown = 0.25
    target_value_under = amount



func set_target_value(amount: float) -> void :
    amount = max(0, amount)
    target_value = amount

    if progress_bar_main.value == amount:
        return

    if progress_bar_main.value > amount:
        progress_bar_main.value = amount




func set_target_over(amount: float) -> void :
    amount = max(0, amount)

    var min_value = Math.get_percentage(progress_bar_main.max_value, target_value)


    if min_value < amount:
        progress_bar_over.value = min_value
        target_value_over = min_value
        return

    if progress_bar_over.value == amount:
        return


    target_value_over = amount





func _process(delta: float) -> void :
    if Engine.is_editor_hint():
        process_label_position()
        return

    process_debuffs_container()

    progress_bar_under_cooldown = max(0, progress_bar_under_cooldown - delta)

    if not progress_bar_under_cooldown and target_value_under < progress_bar_under.value:
        progress_bar_under.value = move_toward(progress_bar_under.value, target_value_under, delta * progress_bar_under.max_value * 2.5)

    if target_value > progress_bar_main.value:
        progress_bar_main.value = move_toward(progress_bar_main.value, target_value, delta * progress_bar_main.max_value)

    if not target_value_over == progress_bar_over.value:
        var speed: float = delta * progress_bar_over.max_value * 3
        progress_bar_over.value = move_toward(progress_bar_over.value, target_value_over, speed)



func process_label_position() -> void :
    if not is_instance_valid(back_panel):
        return

    var size_diff: float = (label_container.size.x - size.x) * 0.5
    label_container.position.x = back_panel.position.x + (back_panel.size.x * 0.5) - (label_container.size.x * 0.5)
    label_container.position.x = maxf(0, label_container.position.x)



func process_debuffs_container() -> void :
    debuffs_container.visible = false

    for child in effect_container_holder.get_children():
        if child is Control:
            if child.visible:
                debuffs_container.visible = true
                return


func _on_label_margin_container_resized() -> void :
    process_label_position()
