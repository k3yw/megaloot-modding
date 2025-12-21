class_name GenericTabContainer extends TabContainer




@export var tab_buttons: Array[TabButton]
var changed_tab_this_frame: bool = false



func _ready() -> void :
    current_tab = 0




func _process(_delta: float) -> void :
    if not Input.is_action_just_pressed("press"):
        return

    for idx in tab_buttons.size():
        var tab_button: TabButton = tab_buttons[idx]
        if UI.is_hovered(tab_button.pressed_panel):
            select_tab(idx)
            return




func select_tab(tab: int) -> void :
    for idx in tab_buttons.size():
        var tab_button: TabButton = tab_buttons[idx]
        tab_button.is_pressed = not idx == tab

    await get_tree().process_frame
    current_tab = tab
    changed_tab_this_frame = true
    await get_tree().process_frame
    changed_tab_this_frame = false
