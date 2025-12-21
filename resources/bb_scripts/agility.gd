extends BBScript





func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("<.>"))
    bb_container_data.push_back(BBContainerData.new(" Determines your chance to "))
    bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.DODGE))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("<.>"))
    bb_container_data.push_back(BBContainerData.new(" Reduced by your "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.ACTIVE_ARMOR))

    return bb_container_data
