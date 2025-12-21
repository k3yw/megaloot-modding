extends StatScript









func initialize() -> void :
    if not is_instance_valid(character):
        return

    if Character.get_item_set_count(character, ItemSets.SILVER) >= 4:
        character.recieved_status_effect.connect(_on_recieved_status_effect)

    battle_procesor.turn_completed.connect( func(_turn_type: BattleTurn.Type):
        try_to_cleanse()
        )



func _on_recieved_status_effect(_status_effect: StatusEffect) -> void :
    await try_to_cleanse()


func try_to_cleanse() -> void :
    var faith: float = character.get_stat_amount(Stats.FAITH)[0]

    if character.get_active_item_sets().has(ItemSets.SILVER) and faith > 0.0:
        await battle_procesor.try_to_cleanse(memory.battle, character)
        return

    if Math.rand_success(faith, RNGManager.gameplay_rand):
        await battle_procesor.try_to_cleanse(memory.battle, character)



func get_amount_to_upgrade(_item: Item, _is_modifier: bool, floor_number: int) -> float:
    return floorf(float(floor_number + 1) * 2.5)
