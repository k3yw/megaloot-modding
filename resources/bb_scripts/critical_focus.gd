extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Your "))
    bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.CRITICAL_STRIKE))
    bb_container_data.push_back(BBContainerData.new(" or "))
    bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.OMNI_CRIT))
    bb_container_data.push_back(BBContainerData.new(" attacks"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("will have +25% "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.ACCURACY))


    return bb_container_data
