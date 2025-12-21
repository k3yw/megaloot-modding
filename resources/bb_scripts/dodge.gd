extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Avoid incoming damage", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("\n"))

    bb_container_data.push_back(BBContainerData.new("Every time you "))
    bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.DODGE))
    bb_container_data.push_back(BBContainerData.new(":"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("reduce "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.AGILITY))
    bb_container_data.push_back(BBContainerData.new(" by 25%"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("resets every battle", Color.DIM_GRAY))

    return bb_container_data
