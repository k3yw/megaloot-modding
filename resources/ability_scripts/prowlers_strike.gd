extends AbilityScript





func _init(gameplay_state: GameplayState, arg_character: Character) -> void :
    super._init(gameplay_state, arg_character)
    character.attack_hit.connect(_on_attack_hit)



func _on_attack_hit(_target: Character, _damage_data: DamageData) -> void :
    if not is_instance_valid(battle_procesor):
        return

    var bonus_ability: BonusStat = BonusStat.new(Stats.AGILITY, 25)
    await character_manager.add_temp_stat(character, bonus_ability)


func can_activate() -> bool:
    for turn in character.battle_profile.get_valid_turns():
        if turn.dodges > 0:
            return true
    return false
