extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Backstab an enemy dealing attack damage"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("<.>"))
    bb_container_data.push_back(BBContainerData.new(" "))
    bb_container_data.push_back(BBContainerData.new("Enemy "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.MAX_HEALTH))
    bb_container_data.push_back(BBContainerData.new(" is above 75%: The damage is reduced by 45%"))

    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("<.>"))
    bb_container_data.push_back(BBContainerData.new(" "))
    bb_container_data.push_back(BBContainerData.new("Enemy "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.MAX_HEALTH))
    bb_container_data.push_back(BBContainerData.new(" is below or equal to 75%: The attack"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("  will be a "))
    bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.CRITICAL_STRIKE))
    bb_container_data.push_back(BBContainerData.new(" and have +25% "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.ACCURACY))



    return bb_container_data
