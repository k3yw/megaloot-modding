extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Your chance to perform the following:"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.LUCKY_ATTACK))

    return bb_container_data
