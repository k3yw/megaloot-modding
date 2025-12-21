extends GameLogicScript









func initialize() -> void :
    if not is_instance_valid(character):
        return

    character.dealt_damage.connect(_on_dealt_damage)


func _on_dealt_damage(damage_result: DamageResult) -> void :
    character_manager.add_temp_stat(character, BonusStat.new(Stats.MAX_HEALTH, damage_result.armor_removed))
