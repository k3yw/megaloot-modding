extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("<.>"))
    bb_container_data.push_back(BBContainerData.new(" Applies 1 stacks of "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.BLINDNESS)
    bb_container_data.push_back(BBContainerData.new(" when entering combat"))

    bb_container_data.push_back(BBContainerData.new("<\n"))

    bb_container_data.push_back(BBContainerData.new("<.>"))
    bb_container_data.push_back(BBContainerData.new(" Opponents get +25% "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.ACCURACY))
    bb_container_data.push_back(BBContainerData.new(" for every "))
    bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.MISS))

    return bb_container_data
