class_name GameObjectCounter extends Object


var item_set_resource: ItemSetResource = Empty.item_set_resource
var item_resource: ItemResource = Empty.item_resource
var amount: int = 0





func _init(arg_resource = null, arg_amount: int = 0) -> void :
    if arg_resource is ItemSetResource:
        item_set_resource = arg_resource

    if arg_resource is ItemResource:
        item_resource = arg_resource

    amount = arg_amount
