extends Node

const HELMET: SocketType = preload("res://resources/socket_types/helmet.tres")
const CHESTPLATE: SocketType = preload("res://resources/socket_types/chestplate.tres")
const LEGGINGS: SocketType = preload("res://resources/socket_types/leggings.tres")
const BOOTS: SocketType = preload("res://resources/socket_types/boots.tres")
const NECKLACE: SocketType = preload("res://resources/socket_types/necklace.tres")

const WEAPON: SocketType = preload("res://resources/socket_types/weapon.tres")
const REPLICATED_WEAPON: SocketType = preload("res://resources/socket_types/replicated_weapon.tres")

const RING: SocketType = preload("res://resources/socket_types/ring.tres")


const BASE_SOCKETS: Array[SocketType] = [
    HELMET, 
    CHESTPLATE, 
    LEGGINGS, 
    BOOTS, 
    NECKLACE, 
    WEAPON, 
    RING
]
