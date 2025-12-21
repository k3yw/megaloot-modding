extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Become "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.ELUSIVE)
    bb_container_data.push_back(BBContainerData.new(" and attack"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("ACTIVATION CONDITION: ", Color.DIM_GRAY))
    bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.BACKSTAB))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("resets every battle", Color.DIM_GRAY))

    return bb_container_data
