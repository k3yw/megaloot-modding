extends BBScript










func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.WOOD, 1))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.WOOD, 1))
    bb_container_data.push_back(BBContainerData.new(" +25% "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.LUCK))
    bb_container_data.push_back(BBContainerData.new("\n"))

    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.WOOD, 3))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.WOOD, 3))
    bb_container_data.push_back(BBContainerData.new(" +10% "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.LUCK))

    return bb_container_data
