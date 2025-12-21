class_name EffectContainerHolder extends Container





func _ready() -> void :
    update_effects([], null)



func update_effects(effects: Array, character: Character) -> void :
    var to_add_count: int = get_child_count() - effects.size()


    if to_add_count < 0:
        for idx in abs(to_add_count):
            var effect_container: EffectContainer = preload("res://scenes/ui/effect_container/effect_container.tscn").instantiate()
            effect_container.character = character
            add_child(effect_container)


    for child in get_children():
        (child as Control).hide()


    if not effects.size():
        return

    for idx in get_child_count():
        var effect_container: EffectContainer = get_child(idx)
        if effects.size() <= idx:
            continue

        if not is_instance_valid(effects[idx]):
            effect_container.set_effect(null)
            effect_container.show()
            continue

        var effect = effects[idx]


        effect_container.status_effect_resource = null
        effect_container.item_set_resource = null
        effect_container.stat_resource = null
        effect_container.character = character

        if effect is StatusEffect:
            var status_effect: StatusEffectResource = effects[idx].resource
            effect_container.set_effect(status_effect, effects[idx].amount)
            effect_container.show()

        if effect is BonusStat:
            var stat: BonusStat = effects[idx]
            effect_container.set_effect(stat.resource, stat.amount)
            effect_container.show()

        if effect is ItemSetResource or effect is Specialization:
            effect_container.set_effect(effect)
            effect_container.show()
