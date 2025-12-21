extends Node

const ADVENTURERS_DIR: String = "res://resources/adventurers/"

var VIRAN: Adventurer = load("res://resources/adventurers/viran.tres")
var KINNO: Adventurer = load("res://resources/adventurers/kinno.tres")
var FREN: Adventurer = load("res://resources/adventurers/fren.tres")
var PYRY: Adventurer = load("res://resources/adventurers/pyry.tres")
var JACE: Adventurer = load("res://resources/adventurers/jace.tres")
var ELYS: Adventurer = load("res://resources/adventurers/elys.tres")
var FAEL: Adventurer = load("res://resources/adventurers/fael.tres")
var RIEL: Adventurer = load("res://resources/adventurers/riel.tres")
var AMON: Adventurer = load("res://resources/adventurers/amon.tres")
var SID: Adventurer = load("res://resources/adventurers/sid.tres")
var TYR: Adventurer = load("res://resources/adventurers/tyr.tres")




var LIST: Array[Adventurer] = [
    FREN, 
    PYRY, 
    SID, 
    ELYS, 
    FAEL, 
    TYR, 
    VIRAN, 
    KINNO, 
    RIEL, 
    AMON, 
    JACE, 
]



var STARTING_ADVENTURERS: Array[Adventurer] = [
    FREN, 
    PYRY, 
    SID, 
]


var DEMO_LIST: Array[Adventurer] = [
    FREN, 
    PYRY, 
    SID, 
]


func get_list() -> Array[Adventurer]:
    if System.is_demo():
        return DEMO_LIST

    return LIST



func get_bb_container_data(adventurer: Adventurer) -> BBContainerData:
    var bb_container_data = BBContainerData.new()
    bb_container_data.text = T.get_translated_string(adventurer.name, "adventurer-name")
    bb_container_data.text_color = Color.LIGHT_STEEL_BLUE
    bb_container_data.adventurer = adventurer

    return bb_container_data


func get_from_name(adventurer_name: String) -> Adventurer:
    for adventurer in LIST:
        if adventurer.name == adventurer_name:
            return adventurer

    return null
