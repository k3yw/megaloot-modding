extends Node


var CONFRONTATION: Trial = load("res://resources/trials/confrontation.tres")
var RESILIENCE: Trial = load("res://resources/trials/resilience.tres")
var SAGACITY: Trial = load("res://resources/trials/sagacity.tres")
var HONOR: Trial = load("res://resources/trials/honor.tres")
var SWARM: Trial = load("res://resources/trials/swarm.tres")



var LIST: Array[Trial] = [
    HONOR, 
    RESILIENCE, 
    SWARM, 
    CONFRONTATION, 
    SAGACITY, 
    ]






func get_bb_container_data(trial: Trial) -> BBContainerData:
    var bb_container_data = BBContainerData.new()
    bb_container_data.text = T.get_translated_string(trial.name, "Trial Name")
    bb_container_data.text_color = Color.LIGHT_STEEL_BLUE
    bb_container_data.trial = trial

    return bb_container_data
