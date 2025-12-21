class_name ToneEvent extends Object



var resource: ToneEventResource
var cooldown: float



func _init(arg_resource: ToneEventResource = ToneEventResource.new()) -> void :
    cooldown = arg_resource.default_cooldown
    resource = arg_resource
