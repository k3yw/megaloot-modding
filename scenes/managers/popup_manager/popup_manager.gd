extends CanvasLayer

signal popup_shown


@export var adventurer_selection_popup: AdventurerSelectionPopup
@export var battle_log_popup_container: BattleLogPopupContainer
@export var adventurer_profile_popup: AdventurerProfilePopup
@export var no_tutorial_popup: PopupContainer
@export var lobby_join_popup: LobbyJoinPopup
@export var lobby_menu_popup: LobbyMenuPopup
@export var credits_popup: CreditsPopup


@export var animation_player: AnimationPlayer
@export var dim_color_rect: ColorRect

@onready var popup_containers: Array[PopupContainer] = get_popup_containers()






func _ready() -> void :
    for child in get_children():
        if child is PopupContainer:
            child.hidden.connect( func(): dim_color_rect.color.a = 0)
            child.hide()






func pop(popup_container: PopupContainer) -> void :
    UI.visible_popups.push_back(popup_container)

    animation_player.stop()
    animation_player.play("dim")

    popup_container.pop()

    popup_shown.emit()



func get_visible_popups() -> Array[CanvasItem]:
    var visible_popups: Array[CanvasItem] = []
    for popup_container in popup_containers:
        if popup_container.visible:
            visible_popups.push_back(popup_container)

    return visible_popups


func should_cover() -> bool:
    for popup_container in popup_containers:
        if popup_container.visible:
            return true

    return false




func get_popup_containers() -> Array[PopupContainer]:
    var popup_containers_arr: Array[PopupContainer] = []

    for child in get_children():
        if child is PopupContainer:
            popup_containers_arr.push_back(child)

    return popup_containers_arr
