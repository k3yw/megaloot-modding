extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []



    bb_container_data.push_back(BBContainerData.new("Upon dropping to 0 ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.HEALTH))
    bb_container_data.push_back(BBContainerData.new(":", Color.DARK_GRAY))

    bb_container_data.push_back(BBContainerData.new("\n"))

    bb_container_data.push_back(BBContainerData.new("<.>"))
    bb_container_data.push_back(BBContainerData.new(" revive and ", Color.DARK_GRAY))
    bb_container_data.push_back(Keywords.get_bb_container_data(Keywords.HEAL))
    bb_container_data.push_back(BBContainerData.new(" for 25% of your ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.MAX_HEALTH))

    bb_container_data.push_back(BBContainerData.new("\n"))


    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.GOLDEN, 3))
    bb_container_data.push_back(BBContainerData.new("<.>"))
    bb_container_data.push_back(BBContainerData.new(" ", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.GOLDEN, 3))
    bb_container_data.push_back(BBContainerData.new(" gain ", Color.DARK_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.INVULNERABILITY)



    return bb_container_data
