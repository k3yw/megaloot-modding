class_name Price extends RefCounted


var type: StatResource
var amount: float




func _init(arg_type: StatResource, arg_amount: float) -> void :
    amount = arg_amount
    type = arg_type
