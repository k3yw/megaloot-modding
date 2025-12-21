extends GameLogicScript







func initialize() -> void :
    battle_procesor.character_received_damage.connect(_on_character_received_damage)


func _on_character_received_damage(target: Character, _attacker: Character, damage_result: DamageResult) -> void :
    if not is_instance_valid(character):
        return

    if not memory.get_opponents(character).has(target):
        return

    if not Math.rand_success(25 + character.get_stat_amount(Stats.LUCK)[0], RNGManager.gameplay_rand):
        return

    if damage_result.damage_type == Stats.ELECTRIC_DAMAGE:
        await battle_procesor.try_to_apply_status_effect(target, character, StatusEffects.STUN)
