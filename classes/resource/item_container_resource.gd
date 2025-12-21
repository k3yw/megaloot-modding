class_name ItemContainerResource extends Resource

const PATH: String = "res://resources/item_containers/"

@export var move_to_inventory_on_alt_press: bool = false
@export var merge_on_buy: bool = false
@export var is_shop: bool = false
@export var size: int




func get_own_name() -> String:
    return resource_path.replace(PATH, "").replace(".tres", "")
