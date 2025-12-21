class_name StatusEffect extends RefCounted





var resource: StatusEffectResource = StatusEffectResource.new()
var amount: float = 0




func _init(arg_resource: StatusEffectResource = StatusEffectResource.new(), arg_amount: float = 1) -> void :
    resource = arg_resource
    amount = arg_amount

    if not arg_resource.name.length():
        amount = 0





static func has_resource(status_effects: Array[StatusEffect], arg_resource: StatusEffectResource) -> bool:
    for status_effect in status_effects:
        if not is_instance_valid(status_effect.resource):
            continue

        if status_effect.resource == arg_resource:
            return true

    return false


static func get_amount(status_effects: Array[StatusEffect], arg_resource: StatusEffectResource) -> float:
    var status_effect_amount: float = 0

    for status_effect in status_effects:
        if not is_instance_valid(status_effect):
            continue

        if not is_instance_valid(status_effect.resource):
            continue

        if status_effect.resource == arg_resource:
            status_effect_amount += status_effect.amount

    return status_effect_amount



static func add(status_effects: Array[StatusEffect], arg_resource: StatusEffectResource, arg_amount: float) -> void :
    for status_effect in status_effects:
        if not is_instance_valid(status_effect):
            continue

        if status_effect.resource == arg_resource:
            status_effect.amount += arg_amount
            return

    var status_effect = StatusEffect.new(arg_resource, arg_amount)
    status_effects.push_back(status_effect)
