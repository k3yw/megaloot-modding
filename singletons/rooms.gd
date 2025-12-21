extends Node


@onready var ENDLESS_MONOLITH: RoomResource = load("res://resources/rooms/endless_monolith.tres")
@onready var ENTRANCE: RoomResource = load("res://resources/rooms/entrance_room.tres")
@onready var FINAL: RoomResource = load("res://resources/rooms/final_room.tres")

@onready var MYSTIC_TRADER: RoomResource = load("res://resources/rooms/mystic_trader.tres")
@onready var MERCHANT: RoomResource = load("res://resources/rooms/merchant_room.tres")
@onready var BATTLE: RoomResource = load("res://resources/rooms/battle_room.tres")
@onready var CHEST: RoomResource = load("res://resources/rooms/chest_room.tres")

@onready var REFORGE_TRANSFER_ROOM: RoomResource = load("res://resources/rooms/reforge_transfer_room.tres")
@onready var ENEMY_UPGRADE: RoomResource = load("res://resources/rooms/enemy_upgrade_room.tres")
@onready var DISMANTLE: RoomResource = load("res://resources/rooms/dismantle_room.tres")

@onready var FOREST_ROOM: RoomResource = load("res://resources/rooms/forest_room.tres")


@onready var LIST: Array[RoomResource] = [
    ENTRANCE, 
    FINAL, 
    MERCHANT, 
    BATTLE, 
    CHEST, 
    ENDLESS_MONOLITH, 
    MYSTIC_TRADER, 
    REFORGE_TRANSFER_ROOM, 
    ENEMY_UPGRADE, 
    DISMANTLE, 
    FOREST_ROOM, 
]
