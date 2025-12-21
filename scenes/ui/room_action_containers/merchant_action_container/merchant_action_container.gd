class_name MerchantActionContainer extends RoomActionContainer



@export var market_container: MarginContainer
@export var refresh_button: GenericButton
@export var leave_button: GenericButton

@export var tinker_container: MarginContainer
@export var tinker_texture_rect: TextureRect
@export var tinker_label: GenericLabel

@export var currency_texture_rect: TextureRect
@export var price_label: GenericLabel


var has_enough_diamonds: bool = true


func _process(_delta: float) -> void :
    tinker_label.set_text_color(0, Color("#665c57"))
    tinker_texture_rect.modulate = Color("#665c57")

    currency_texture_rect.modulate = Color("#665c57")
    price_label.set_text_color(0, Color("#665c57"))

    if not has_enough_diamonds:
        currency_texture_rect.modulate = Color("#b42045")
        price_label.set_text_color(0, Color("#b42045"))

    if UI.is_hovered(tinker_container) and has_enough_diamonds:
        tinker_label.set_text_color(0, Color.DARK_ORANGE)
        tinker_texture_rect.modulate = Color.DARK_ORANGE

        currency_texture_rect.modulate = Color.DARK_ORANGE
        price_label.set_text_color(0, Color.DARK_ORANGE)
