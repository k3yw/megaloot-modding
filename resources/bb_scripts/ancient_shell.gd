extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []


    bb_container_data.push_back(BBContainerData.new("If you used a stance this turn:"))

    bb_container_data.push_back(BBContainerData.new("\n"))

    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.ANCIENT_SHELL, 1))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.ANCIENT_SHELL, 1))

    bb_container_data.push_back(BBContainerData.new(" "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.TOUGHNESS))
    bb_container_data.push_back(BBContainerData.new(" will reduce all types of damage"))

    bb_container_data.push_back(BBContainerData.new("\n"))

    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.ANCIENT_SHELL, 3))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.ANCIENT_SHELL, 3))
    bb_container_data.push_back(BBContainerData.new(" Receive "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.EPHEMERAL_SHELL)
    bb_container_data.push_back(BBContainerData.new(" at the end of the turn"))

    bb_container_data.push_back(BBContainerData.new("\n"))

    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.ANCIENT_SHELL, 5))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.ANCIENT_SHELL, 5))
    bb_container_data.push_back(BBContainerData.new(" Removes "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.EPHEMERAL_LOCK)
    bb_container_data.push_back(BBContainerData.new(" at the end of the turn"))

    return bb_container_data
