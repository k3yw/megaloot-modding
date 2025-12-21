class_name Ability extends RefCounted



var resource: AbilityResource = AbilityResource.new()
var mimicked: bool = false



func _init(arg_resource: AbilityResource = resource, arg_mimicked: bool = mimicked) -> void :
    resource = arg_resource
    mimicked = arg_mimicked
