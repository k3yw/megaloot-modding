extends GameLogicScript







func initialize() -> void :
    if not is_instance_valid(character):
        return


    character.stat_changed.connect( func(stat_resource: StatResource, old_amount: float):
        if not stat_resource == Stats.ACTIVE_ARMOR:
            return

        if old_amount <= 0.0:
            return

        var new_active_armor: float = character.get_stat_amount(Stats.ACTIVE_ARMOR)[0]

        if old_amount >= 0.0 and new_active_armor <= 0.0:
            await battle_manager.create_battle_animation_timer(0.75)

            var amount: float = ceilf(character.get_health() * 0.1)
            var iron_pact_damage_result = DamageResult.new(memory.get_character_reference(character))
            iron_pact_damage_result.source = DamageData.Source.IRON_PACT
            iron_pact_damage_result.direct_damage = amount

            await battle_procesor.directly_damage(iron_pact_damage_result)
            character.change_active_armor(amount)
        )
