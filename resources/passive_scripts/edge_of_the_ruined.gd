extends GameLogicScript









func initialize() -> void :
    if not is_instance_valid(character):
        return

    character.about_to_attack.connect( func(target: Character, damage_data: DamageData):
        if character.battle_profile.has_active_status_effect_resource(StatusEffects.BLACK_CURSE)\
or character.battle_profile.has_active_status_effect_resource(StatusEffects.CURSE):
            damage_data.damage += target.get_health() * 0.11
    )
