extends Node

const DIR: String = "res://resources/specializations/"

var BLOODCASTER: Specialization = load("res://resources/specializations/bloodcaster.tres")
var DEBILITATOR: Specialization = load("res://resources/specializations/debilitator.tres")
var CINDERTHORN: Specialization = load("res://resources/specializations/cinderthorn.tres")
var CHROMATHORN: Specialization = load("res://resources/specializations/chromathorn.tres")
var CHROMAGUARD: Specialization = load("res://resources/specializations/chromaguard.tres")
var CHROMASPITE: Specialization = load("res://resources/specializations/chromaspite.tres")
var INVULNERIUM: Specialization = load("res://resources/specializations/invulnerium.tres")
var MINDBREAKER: Specialization = load("res://resources/specializations/mindbreaker.tres")
var MOONLIGHTER: Specialization = load("res://resources/specializations/moonlighter.tres")
var THORNFROST: Specialization = load("res://resources/specializations/thornfrost.tres")
var ECHOMANCER: Specialization = load("res://resources/specializations/echomancer.tres")
var WINDWALKER: Specialization = load("res://resources/specializations/windwalker.tres")
var VAMPIERCER: Specialization = load("res://resources/specializations/vampiercer.tres")
var FAITHBOUND: Specialization = load("res://resources/specializations/faithbound.tres")
var THUNDERBORN: Specialization = load("res://resources/specializations/thunderborn.tres")
var CHALLENGER: Specialization = load("res://resources/specializations/challenger.tres")
var NIGHTHRUST: Specialization = load("res://resources/specializations/nighthrust.tres")
var BEASTBOUND: Specialization = load("res://resources/specializations/beastbound.tres")
var QUICKBLADE: Specialization = load("res://resources/specializations/quickblade.tres")
var BLOODMOON: Specialization = load("res://resources/specializations/bloodmoon.tres")
var MINDTHORN: Specialization = load("res://resources/specializations/mindthorn.tres")
var HARBINGER: Specialization = load("res://resources/specializations/harbinger.tres")
var LIONHEART: Specialization = load("res://resources/specializations/lionheart.tres")
var DESERTER: Specialization = load("res://resources/specializations/deserter.tres")
var VENOMIRE: Specialization = load("res://resources/specializations/venomire.tres")
var RAMPAGER: Specialization = load("res://resources/specializations/rampager.tres")
var EVADIUM: Specialization = load("res://resources/specializations/evadium.tres")
var PURSUER: Specialization = load("res://resources/specializations/pursuer.tres")
var STRIKER: Specialization = load("res://resources/specializations/striker.tres")
var STUNIUM: Specialization = load("res://resources/specializations/stunium.tres")


class SpecializationArray:
    var arr: Array[Specialization] = []
    func _init(arg_arr: Array[Specialization]) -> void :
        arr = arg_arr


var LIST: Dictionary[ItemSetResource, SpecializationArray] = {}



func _ready() -> void :
    for file_name in File.get_file_paths(DIR):
        var file_path: String = DIR + file_name

        if ".tres.remap" in file_path:
            file_path = file_path.trim_suffix(".remap")

        var specialization: Specialization = load(file_path)

        if not is_instance_valid(specialization):
            print("invalid specialization at: ", file_path)
            continue

        if not LIST.has(specialization.original_item_set):
            LIST[specialization.original_item_set] = SpecializationArray.new([specialization])
            continue
        LIST[specialization.original_item_set].arr.push_back(specialization)
