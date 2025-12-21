class_name HubActionPanel extends MarginContainer


@export var split_container: MarginContainer
@export var sell_container: MarginContainer

@export var press_texture_rect: TextureRect
@export var price_container: HBoxContainer
@export var gold_coins_icon: TextureRect

@export var price_label: Label

@export var split_texture_rect: TextureRect
@export var split_label: GenericLabel


var hover_color: Color = Color("f9a31b")




func _process(_delta: float) -> void :
    split_label.set_text_color(0, Color("#665c57"))
    split_texture_rect.modulate = Color("#665c57")
    price_container.modulate = Color("#665c57")

    if UI.is_hovered(sell_container):
        price_container.modulate = hover_color

    if UI.is_hovered(split_container):
        split_label.set_text_color(0, Color.DARK_ORANGE)
        split_texture_rect.modulate = Color.DARK_ORANGE

    press_texture_rect.texture = Action.get_alt_press_texture()





func set_price(price: float) -> void :
    price_label.text = "+" + Format.number(price, [Format.Rules.USE_SUFFIX])

    price_label.visible = price > 0
    gold_coins_icon.visible = price > 0

    hover_color = Color("f9a31b")
