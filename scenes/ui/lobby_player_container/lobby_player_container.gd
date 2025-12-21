class_name LobbyPlayerContainer extends MarginContainer


@export var adventurer_portrait: AdventurerPortrait
@export var select_adventurer_label: GenericLabel
@export var swap_texture_rect: TextureRect
@export var name_label: GenericLabel


var own_container: bool = false
var disabled: bool = false

func _ready() -> void :
    select_adventurer_label.hide()
    swap_texture_rect.hide()


func _process(_delta: float) -> void :
    if not own_container or disabled:
        return

    var portrait_alpha: float = adventurer_portrait.alpha
    swap_texture_rect.hide()

    if UI.is_hovered(adventurer_portrait):
        if Input.is_action_just_pressed("press"):
            PopupManager.pop(PopupManager.adventurer_selection_popup)

        portrait_alpha = portrait_alpha * 0.5
        swap_texture_rect.show()

    adventurer_portrait.shader.set_shader_parameter("alpha", portrait_alpha)
