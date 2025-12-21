class_name BBCounter extends RefCounted



var item_set_resource: ItemSetResource
var stat_resource: StatResource
var amount: int = 0






func _init(arg_resource, arg_amount: int = 0) -> void :
    if arg_resource is ItemSetResource:
        item_set_resource = arg_resource

    if arg_resource is StatResource:
        stat_resource = arg_resource

    amount = arg_amount
