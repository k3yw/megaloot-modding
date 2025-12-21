extends GameLogicScript





func initialize() -> void :
    if not is_instance_valid(character):
        return

    character.attack_avoided.connect( func(attacker: Character, damage_data: DamageData):
        var shadow_count: int = Character.get_item_set_count(character, ItemSets.SHADOW)
        if shadow_count > 0:
            await battle_procesor.try_to_backstab(memory.battle, character, attacker)

        if shadow_count >= 3 and character.battle_profile.has_active_status_effect_resource(StatusEffects.ELUSIVE):
            character_manager.add_temp_stat(character, BonusStat.new(Stats.ADAPTIVE_ATTACK, damage_data.damage))
        )
