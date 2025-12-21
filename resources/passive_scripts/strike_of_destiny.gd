extends GameLogicScript






func _init(arg_arr: Array = []) -> void :
    super._init(arg_arr)

    character.attack_hit.connect( func(target: Character, _damage_data: DamageData):
        if character.battle_profile.has_active_status_effect_resource(StatusEffects.INVULNERABILITY):
            target.battle_profile.remove_buffs()
    )
