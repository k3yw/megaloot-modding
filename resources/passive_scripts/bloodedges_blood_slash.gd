extends GameLogicScript






func initialize() -> void :
    if not is_instance_valid(character):
        return

    character.about_to_attack.connect( func(_target: Character, _damage_data: DamageData):
        var amount: float = ceilf(character.get_health() * 0.1)
        var damage_result = DamageResult.new(memory.get_character_reference(character))
        damage_result.source = DamageData.Source.LIFE_FOR_POWER_BLOOD_SLASH
        damage_result.direct_damage = amount

        await battle_procesor.directly_damage(damage_result)
        character_manager.add_temp_stat(character, BonusStat.new(Stats.PHYSICAL_ATTACK, amount), true)
    )
