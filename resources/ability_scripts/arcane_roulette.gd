extends AbilityScript



func activate(arg_battle_procesor: BattleProcesor) -> void :
    await super.activate(arg_battle_procesor)
    character.magic_shield_broke.connect(_on_magic_shield_broke)


func _on_magic_shield_broke() -> void :
    if not is_instance_valid(battle_procesor):
        return

    var rand_enemy: Enemy = memory.battle.get_random_enemy_in_combat()
    await battle_procesor.attack_character(memory.battle, rand_enemy, character, DamageData.Source.ATTACK)


func can_activate() -> bool:
    return character.battle_profile.has_active_status_effect_resource(StatusEffects.MAGIC_SHIELD)
