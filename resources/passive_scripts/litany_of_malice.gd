extends GameLogicScript








func initialize() -> void :
    if not is_instance_valid(character):
        return

    character.about_to_receive_damage.connect(_on_about_to_receive_damage)



func _on_about_to_receive_damage(target: Character, damage_data: DamageData) -> void :
    if not damage_data.type == Stats.MALICE_DAMAGE:
        return
    damage_data.apply_multiplier(1.0 + (0.25 * target.battle_profile.active_status_effects.size()))
