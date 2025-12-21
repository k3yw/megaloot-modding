extends Node

const PATH: String = "res://resources/game_modes/"

var CHALLENGE: GameMode = load("res://resources/game_modes/challenge.tres")
var PVP: GameMode = load("res://resources/game_modes/pvp.tres")
var PRACTICE: GameMode = load("res://resources/game_modes/practice.tres")


var LIST: Array[GameMode] = [
    CHALLENGE, 
    PVP, 
    PRACTICE, 
]




func from_name(arg_name: String) -> GameMode:
    return load(PATH + arg_name.to_lower() + ".tres")
