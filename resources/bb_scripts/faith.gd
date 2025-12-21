extends BBScript





func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("<.>"))
    bb_container_data.push_back(BBContainerData.new(" Determines your chance to "))
    bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.CLEANSE))
    bb_container_data.push_back(BBContainerData.new(":"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.SILVER, 0))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.SILVER, 0))
    bb_container_data.push_back(BBContainerData.new(" At the end of the turn"))
    bb_container_data.push_back(BBContainerData.new("\n"))

    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.SILVER, 4))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.SILVER, 4))
    bb_container_data.push_back(BBContainerData.new(" When you receive a debuff"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("\n"))

    bb_container_data.push_back(BBContainerData.new("<.>"))
    bb_container_data.push_back(BBContainerData.new(" Reduced by your "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.GREED))



    return bb_container_data
