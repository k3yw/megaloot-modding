@tool
class_name PopupContainer extends CanvasGroup


@export var animation_player: AnimationPlayer
@export var container: MarginContainer
@export var close_button: CloseButton

@export_tool_button("fix_position") var fix_position_press = fix_position

func _ready() -> void :
    if not Engine.is_editor_hint():
        return
    fix_position()


func fix_position() -> void :
    container.position.x = 320 - roundi(container.size.x * 0.5)
    container.position.y = 180 - roundi(container.size.y * 0.5)
    print("fixed position")

func pop() -> void :
    animation_player.stop()
    animation_player.play("show")


func _process(_delta: float) -> void :
    if not Engine.is_editor_hint() and Input.is_action_just_pressed("alt_press"):
        hide()

    container.size.y = 0


    if Engine.is_editor_hint():
        return

    if is_instance_valid(close_button):
        if close_button.is_pressed:
            hide()


func _on_hidden() -> void :
    UI.visible_popups.erase(self)
