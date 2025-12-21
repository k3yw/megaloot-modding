class_name PartnerContainer extends MarginContainer

@export var adventurer_portrait: AdventurerPortrait
@export var border_texture_rect: TextureRect
@export var action_texture_rect: TextureRect

@export var lock_texture_rect: TextureRect


var is_pressed: bool = false



func _ready() -> void :
    show_as_normal()





func _process(_delta: float) -> void :
    is_pressed = false

    if UI.is_hovered(self) and Input.is_action_just_pressed("press"):
        is_pressed = true







func show_as_normal() -> void :
    adventurer_portrait.portrait_canvas_group.modulate.a = 1.0
    action_texture_rect.hide()


func show_as_attacking() -> void :
    adventurer_portrait.portrait_canvas_group.modulate.a = 0.25
    action_texture_rect.texture = preload("res://assets/textures/icons/stats/physical_damage_icon.png")
    action_texture_rect.show()

func show_as_waiting() -> void :
    adventurer_portrait.portrait_canvas_group.modulate.a = 0.25
    action_texture_rect.texture = preload("res://assets/textures/icons/timeout_icon.png")
    action_texture_rect.show()

func show_as_sorting() -> void :
    adventurer_portrait.portrait_canvas_group.modulate.a = 0.25
    action_texture_rect.texture = preload("res://assets/textures/icons/inventory_icon.png")
    action_texture_rect.show()


func show_as_to_gift() -> void :
    adventurer_portrait.portrait_canvas_group.modulate.a = 0.25
    action_texture_rect.texture = preload("res://assets/textures/icons/gift_icon.png")
    action_texture_rect.show()


func show_as_left() -> void :
    adventurer_portrait.portrait_canvas_group.modulate.a = 0.25
    action_texture_rect.texture = preload("res://assets/textures/ui/leave_icon.png")
    action_texture_rect.show()



func _on_lock_texture_rect_visibility_changed() -> void :
    var sound: AudioStream = preload("res://assets/sfx/lock_item.wav")

    if not lock_texture_rect.visible:
        sound = preload("res://assets/sfx/unlock_item.wav")

    var tone_event: ToneEventResource = ToneEventResource.new()
    tone_event.tones.push_back(Tone.new(sound, -4.5))
    tone_event.space_type = ToneEventResource.SpaceType._2D
    tone_event.position = global_position
    AudioManager.play_event(tone_event, name)
