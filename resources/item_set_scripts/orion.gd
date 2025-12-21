extends GameLogicScript







func initialize() -> void :
    if not is_instance_valid(character):
        return

    character.about_to_receive_damage.connect(_on_about_to_receive_damage)
    battle_procesor.turn_completed.connect(_on_turn_completed)



func _on_about_to_receive_damage(_attacker: Character, damage_data: DamageData) -> void :
        var multiplier: float = maxf(0.25, character.get_health_percent() * 0.01)
        damage_data.apply_multiplier(multiplier)


func _on_turn_completed(_turn_type: BattleTurn.Type) -> void :
    if Character.get_item_set_count(character, ItemSets.ORION) >= 3:
        var amount: float = StatUtils.multiply(character.get_stat_amount(Stats.ARMOR)[0], 25)
        character.change_active_armor(amount)
