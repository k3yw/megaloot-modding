extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("If your attack leaves the target with 75%"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.ACTIVE_ARMOR))
    bb_container_data.push_back(BBContainerData.new(" or below, "))
    bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.ARMOR_BREAK))

    return bb_container_data
