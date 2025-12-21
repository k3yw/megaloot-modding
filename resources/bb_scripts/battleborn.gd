extends BBScript










func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Every time you ", Color.DARK_GRAY))
    bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.PARRY))
    bb_container_data.push_back(BBContainerData.new(", ", Color.DARK_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.STUN)
    bb_container_data.push_back(BBContainerData.new(" the target", Color.DARK_GRAY))

    return bb_container_data
