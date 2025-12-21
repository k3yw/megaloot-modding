extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []



    bb_container_data.push_back(BBContainerData.new("Receive an ", Color.DARK_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.INHERITED_SIN)
    bb_container_data.push_back(BBContainerData.new(" on the first turn", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("\n"))

    bb_container_data.push_back(BBContainerData.new("If ", Color.DARK_GRAY))
    bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.CLEANSE))
    bb_container_data.push_back(BBContainerData.new(" removed ", Color.DARK_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.INHERITED_SIN)

    bb_container_data.push_back(BBContainerData.new(", gain 5", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("stacks of ", Color.DARK_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.DEBUFF_IMMUNITY)


    return bb_container_data
