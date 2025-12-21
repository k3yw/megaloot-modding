extends AbilityScript






func can_activate() -> bool:
    return true




func get_status_effects_on_hit(arg_character: Character) -> Array[StatusEffect]:
    var status_effects_on_hit: Array[StatusEffect] = []

    if not arg_character == character:
        return []

    status_effects_on_hit.push_back(StatusEffect.new(StatusEffects.WEAKNESS, 3))

    return status_effects_on_hit
