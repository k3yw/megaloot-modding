extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Your attacks will apply debuffs you removed"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("via "))
    bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.CLEANSE))
    bb_container_data.push_back(BBContainerData.new(" (resets every battle)"))

    return bb_container_data
