class_name ItemTextureRect extends Control


@onready var visibility_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var merge_texture_rect: TextureRect = $MergeTextureRect
@onready var rarity_texture_rect: TextureRect = $CanvasGroup / RarityTextureRect
@onready var activation_texture_bar: TextureRect = $CanvasGroup / ActivationProgressBar
@onready var outline_texture_rect: TextureRect = $OutlineTextureRect
@onready var shine_rect: ColorRect = $CanvasGroup / ShineRect
@onready var upgrade_mark_texture_rect: TextureRect = $CanvasGroup / UpgradeMarkTextureRect
@onready var burnout_progress_bar: ProgressBar = $CanvasGroup / BurnoutProgressBar
@onready var reforged_texture_rect: TextureRect = $CanvasGroup / ReforgedTextureRect
@onready var discount_texture_rect: TextureRect = $CanvasGroup / DiscountTextureRect
@onready var highlight_texture_rect: TextureRect = $HighlightTextureRect
@onready var item_glow_effect: ItemGlowEffect = $ItemGlowEffect
@onready var lock_texture_rect: TextureRect = $LockTextureRect
@onready var icon_texture_rect: TextureRect = $CanvasGroup / IconTextureRect
@onready var debug_label: Label = $CanvasGroup / DebugLabel
@onready var canvas_group: CanvasGroup = $CanvasGroup


var enable_glow_this_frame: bool
var rarity_color_overriden_this_frame: bool
var shine_overriden_this_frame: bool
var rarity_hue_overriden_this_frame: bool
var outline_enabled: bool = true


var default_color: Color = Color.WHITE
var default_alpha: float = 1.0

var default_rarity_color: Color
var glow_color: Color = Color.WHITE

var slot_reference: Control

var max_progress: float
var curr_progress: float

var amount: int

var hue_texture: GradientTexture1D
var hue_strength: float

var base_saturation: float = 1.0
var shine_alpha: float

var hovered_last_frame: bool = false
var hovering: bool = false

var disabled: bool = false

var item_resource: ItemResource = null
var is_banish: bool = false
var is_buyout: bool = false

func _ready():
	set_rarity_texture_rect_modulate(default_rarity_color)
	set_rarity_hue_effect(hue_texture, hue_strength)
	set_shine_rect_alpha(shine_alpha)

	upgrade_mark_texture_rect.hide()
	reforged_texture_rect.hide()
	discount_texture_rect.hide()
	burnout_progress_bar.hide()
	outline_texture_rect.hide()
	lock_texture_rect.hide()

	process_activation_progress()
	update_visible_on_screen()




func _process(delta: float) -> void :
	if disabled:
		return

	hovering = UI.is_hovered(self)

	process_rarity_col()
	process_rarity_hue()
	process_shine()

	process_activation_progress()

	process_rarity_glow()


	process_outline_texture_rect()

	process_audio()


	enable_glow_this_frame = false
	shine_overriden_this_frame = false
	rarity_color_overriden_this_frame = false
	hovered_last_frame = hovering






func apply_data(item_texture_rect_data: ItemTextureRectData):
	var reforged_border_texture: AtlasTexture = (reforged_texture_rect.texture as AtlasTexture)
	var item_texture: Texture = preload("res://assets/textures/items/unknown.png")
	var item: Item = item_texture_rect_data.item

	item_resource = item.resource
	is_banish = item.is_banish
	is_buyout = item.is_buyout

	if is_instance_valid(item_texture_rect_data.slot_reference):
		slot_reference = item_texture_rect_data.slot_reference

		if not item_texture_rect_data.slot_reference.visibility_changed.is_connected(_on_slot_reference_visibility_changed):
			item_texture_rect_data.slot_reference.visibility_changed.connect(_on_slot_reference_visibility_changed)


	var rarity_texture: Texture2D = ItemRarity.get_texture(item.rarity)

	if is_instance_valid(item.resource):
		item_texture = item.get_texture()

		if item.resource.is_essential():
			rarity_texture = preload("res://assets/textures/rarity_borders/toggle_off_border.png")
			if item.toggled:
				rarity_texture = preload("res://assets/textures/rarity_borders/toggle_on_border.png")

		if item.resource.is_consumable() or item.resource.is_tome() or item.resource.is_special or item.is_banish or item.is_buyout:
			rarity_texture = preload("res://assets/textures/rarity_borders/toggle_off_border.png")
		
		if item.is_buyout:
			rarity_texture = preload("res://assets/textures/rarity_borders/toggle_on_border.png")
			
	icon_texture_rect.texture = item_texture

	reforged_border_texture.region.position.x = min(reforged_border_texture.atlas.get_size().x - 34, (item.reforge_level - 1) * 34)
	reforged_texture_rect.modulate.a = int(item.reforge_level > 0)
	if is_banish:
		reforged_texture_rect.modulate.a = 0.0
	#if is_buyout:
	#	reforged_texture_rect.modulate.a = 0.5

	rarity_texture_rect.texture = rarity_texture

	default_rarity_color = Color.WHITE

	hue_texture = ItemRarity.get_hue_texture(item.rarity)
	hue_strength = ItemRarity.get_hue_strength(item.rarity)


	shine_alpha = ItemRarity.get_shine_alpha(item.rarity)


	if item.has_transformer_stat():
		set_item_texture_rect_gray_scale_overlay(item.transform_stat.color)


	set_item_texture_rect_modulate(Color.WHITE)
	set_item_texture_rect_wobble(0.0)
	base_saturation = 1.0
	default_alpha = 1.0

	if item.is_phantom:
		set_item_texture_rect_modulate(Color.CYAN)
		set_item_texture_rect_wobble(1.7)
		default_alpha = 0.75

	if item.is_reforge:
		set_item_texture_rect_modulate(Color.LIGHT_BLUE)
		set_item_texture_rect_wobble(1.7)
		base_saturation = 0.25
		default_alpha = 0.75

	if is_banish:
		set_item_texture_rect_modulate(Color.PALE_VIOLET_RED)
		set_item_texture_rect_wobble(1.7)
		base_saturation = 0.25
		default_alpha = 0.75
		
	if is_buyout:
		set_item_texture_rect_modulate(Color.DARK_SEA_GREEN)
		set_rarity_texture_rect_modulate(Color.DARK_SEA_GREEN)
		set_item_texture_rect_wobble(2)
		base_saturation = 0.25
		default_alpha = 0.75

	update_visibility()




func _on_slot_reference_visibility_changed() -> void :
	update_visibility()



func update_position() -> void :
	if is_instance_valid(slot_reference):
		position = Vector2(1, 1)



func update_visibility() -> void :
	if is_instance_valid(slot_reference):
		visible = slot_reference.is_visible_in_tree()





func play_upgrade_visuals(rarity: ItemRarity.Type, skip_rarity: bool = false) -> void :
	set_rarity_glow_texture(rarity_texture_rect.texture)
	if not skip_rarity:
		set_rarity_glow_texture(ItemRarity.get_texture(rarity))
		set_rarity_hue_effect(ItemRarity.get_hue_texture(rarity), ItemRarity.get_hue_strength(rarity))
		set_shine_rect_alpha(ItemRarity.get_shine_alpha(rarity))

	enable_glow_this_frame = true
	rarity_hue_overriden_this_frame = true
	shine_overriden_this_frame = true




func process_activation_progress():
	var fill_ratio: float = (1.0 / max_progress) * curr_progress
	if not max_progress or not curr_progress:
		fill_ratio = 1.0

	(activation_texture_bar.material as ShaderMaterial).set_shader_parameter("fill_ratio", fill_ratio)


	var modulate_ratio = 1.0 - ((1.0 / 1.25) * fill_ratio)
	canvas_group.self_modulate.a = modulate_ratio

	if not shine_overriden_this_frame:
		set_shine_rect_alpha(modulate_ratio * shine_alpha)


	if not max_progress or not curr_progress:
		canvas_group.self_modulate.a = 1.0

		if not shine_overriden_this_frame:
			set_shine_rect_alpha(shine_alpha)







func process_rarity_col() -> void :
	if rarity_color_overriden_this_frame:
		return

	merge_texture_rect.modulate.a = 0
	set_rarity_texture_rect_modulate(default_rarity_color)
	(rarity_texture_rect.material as ShaderMaterial).set_shader_parameter("ratio", 0)



func process_rarity_hue() -> void :
	if rarity_hue_overriden_this_frame:
		return

	set_rarity_hue_effect(hue_texture, hue_strength)
	rarity_hue_overriden_this_frame = false




func process_rarity_glow() -> void :
	if not enable_glow_this_frame:
		return

	var ratio: float = abs(sin(UIManager.item_time * 4.5))
	set_rarity_texture_rect_modulate(lerp(default_rarity_color, glow_color, ratio))
	set_rarity_texture_rect_ratio(ratio)
	set_item_texture_rect_ratio(ratio)
	merge_texture_rect.modulate.a = ratio * 0.75





func process_shine() -> void :
	if shine_overriden_this_frame:
		return

	set_shine_rect_alpha(shine_alpha)



func process_outline_texture_rect() -> void :
	if outline_enabled and hovering:
		outline_texture_rect.show()
		return

	outline_texture_rect.hide()







func process_audio():
	if hovered_last_frame == hovering:
		return

	if not hovering:
		return


	var tone_event: ToneEventResource = ToneEventResource.new()
	var tone = Tone.new(preload("res://assets/sfx/item_hover.wav"), -12.5)
	var pitch_scale: float = 1.0 + (float(position.length()) * 0.001)
	tone_event.space_type = ToneEventResource.SpaceType._2D
	tone_event.position = global_position
	tone_event.tones.push_back(tone)
	tone_event.stackable = true
	tone.pitch_min = pitch_scale
	tone.pitch_max = pitch_scale

	AudioManager.play_event(tone_event, StateManager.get_current_state().name)





func set_rarity_glow_texture(glow_texture: Texture2D):
	(rarity_texture_rect.material as ShaderMaterial).set_shader_parameter("new_tex", glow_texture)




func set_rarity_hue_effect(arg_hue_texture: GradientTexture1D, arg_hue_strength: float):
	if not is_instance_valid(arg_hue_texture):
		(icon_texture_rect.material as ShaderMaterial).set_shader_parameter("strength", 0)
		(rarity_texture_rect.material as ShaderMaterial).set_shader_parameter("strength", 0)
		return

	(icon_texture_rect.material as ShaderMaterial).set_shader_parameter("hue_tex", arg_hue_texture)
	(icon_texture_rect.material as ShaderMaterial).set_shader_parameter("strength", arg_hue_strength)
	(rarity_texture_rect.material as ShaderMaterial).set_shader_parameter("hue_tex", arg_hue_texture)
	(rarity_texture_rect.material as ShaderMaterial).set_shader_parameter("strength", arg_hue_strength * 0.25)
	(rarity_texture_rect.material as ShaderMaterial).set_shader_parameter("speed", 0.3)



func set_item_texture_rect_modulate(color: Color) -> void :
	(icon_texture_rect.material as ShaderMaterial).set_shader_parameter("modulate", color)

func set_item_texture_rect_gray_scale_overlay(color: Color) -> void :
	(icon_texture_rect.material as ShaderMaterial).set_shader_parameter("gray_scale_overlay", color)

func set_item_texture_rect_alpha(alpha: float) -> void :
	(icon_texture_rect.material as ShaderMaterial).set_shader_parameter("alpha", alpha)

func set_item_texture_rect_wobble(wobble: float) -> void :
	(icon_texture_rect.material as ShaderMaterial).set_shader_parameter("wobble", wobble)

func set_item_texture_rect_ratio(ratio: float) -> void :
	(icon_texture_rect.material as ShaderMaterial).set_shader_parameter("ratio", ratio)

func set_saturation(saturation: float) -> void :
	(icon_texture_rect.material as ShaderMaterial).set_shader_parameter("saturation", minf(base_saturation, saturation))

func set_rarity_texture_rect_ratio(ratio: float) -> void :
	(rarity_texture_rect.material as ShaderMaterial).set_shader_parameter("ratio", ratio)


func set_rarity_texture_rect_modulate(color: Color) -> void :
	(rarity_texture_rect.material as ShaderMaterial).set_shader_parameter("modulate", color)


func set_rarity_texture_rect_alpha(alpha: float) -> void :
	(rarity_texture_rect.material as ShaderMaterial).set_shader_parameter("alpha", alpha)


func set_shine_rect_alpha(alpha: float) -> void :
	(shine_rect.material as ShaderMaterial).set_shader_parameter("alpha", alpha)


func set_upgrade_mark_main_color(color: Color) -> void :
	(upgrade_mark_texture_rect.material as ShaderMaterial).set_shader_parameter("modulate", color)

func set_upgrade_mark_outline_color(color: Color) -> void :
	(upgrade_mark_texture_rect.material as ShaderMaterial).set_shader_parameter("outline_modulate", color)




func _on_visible_on_screen_notifier_2d_screen_exited() -> void :
	update_visible_on_screen()


func _on_visible_on_screen_notifier_2d_screen_entered() -> void :
	update_visible_on_screen()




func set_as_multiply() -> void :
	canvas_group.material = CanvasItemMaterial.new()
	(canvas_group.material as CanvasItemMaterial).blend_mode = CanvasItemMaterial.BLEND_MODE_MUL



func update_visible_on_screen() -> void :
	if visibility_notifier.is_on_screen():
		(icon_texture_rect.material as ShaderMaterial).set_shader_parameter("disabled", false)
		reforged_texture_rect.show()
		rarity_texture_rect.show()
		merge_texture_rect.show()
		icon_texture_rect.show()
		shine_rect.show()
		set_process(true)
		disabled = false
		return


	for child in canvas_group.get_children():
		if child is CanvasItem:
			child.hide()

	(icon_texture_rect.material as ShaderMaterial).set_shader_parameter("disabled", true)
	set_process(false)
	disabled = true
