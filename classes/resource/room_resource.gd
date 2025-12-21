class_name RoomResource extends Resource


@export var restless: bool = false

@export var scene: PackedScene = preload("res://scenes/rooms/room_normal.tscn")
@export var enemy_h_seperation: float = 20.0

@export var action_container_scene: PackedScene
@export var processor_script: GDScript
