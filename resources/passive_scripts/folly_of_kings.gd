extends GameLogicScript




func initialize() -> void :
    if not is_instance_valid(character):
        return

    var rand_status_effect: StatusEffectResource = StatusEffects.get_random_status_effect(RNGManager.gameplay_rand, [
        StatusEffectTypes.DEBUFF, 
        StatusEffectTypes.BUFF, 
        ])

    await battle_procesor.try_to_apply_status_effect(character, character, rand_status_effect)

    if character.get_turn_size() % 2 == 0:
        var strongest_enemy: Enemy = null
        var damage: float = 0.0

        for enemy in memory.battle.get_enemies_in_combat():
            var enemy_attack_damage_data: DamageData = enemy.get_attack_damage_data(DamageData.Source.ATTACK)
            enemy.apply_damage_output_boosters(enemy_attack_damage_data)

            if not is_instance_valid(strongest_enemy):
                damage = enemy_attack_damage_data.damage
                strongest_enemy = enemy
                continue

            if enemy_attack_damage_data.damage > damage:
                damage = enemy_attack_damage_data.damage
                strongest_enemy = enemy

        battle_procesor.polymorph(memory.battle, memory.battle.get_enemy_idx_from_character(strongest_enemy))
