extends BBScript












func get_bb_container_data(args: Array = []) -> Array[BBContainerData]:
    var specialization: Specialization = args[0] as Specialization
    var bb_container_data: Array[BBContainerData] = []

    match specialization:
        Specializations.MINDBREAKER:
            bb_container_data.push_back(BBContainerData.new("<.>"))
            bb_container_data.push_back(BBContainerData.new(" Apply 2 stacks of ", Color.DARK_GRAY))
            bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.MADNESS)
            bb_container_data.push_back(BBContainerData.new(" to enemies with ", Color.DARK_GRAY))
            bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.CONFUSION)
            bb_container_data.push_back(BBContainerData.new("\n"))

        Specializations.DEBILITATOR: pass

    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.DARKNESS, 1))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.DARKNESS, 1))
    bb_container_data.push_back(BBContainerData.new(" Apply ", Color.DARK_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.FEAR)
    bb_container_data.push_back(BBContainerData.new(" to all enemies with lower attack damage", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("  than you at the start of the turn", Color.DARK_GRAY))


    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.DARKNESS, 3))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.DARKNESS, 3))
    bb_container_data.push_back(BBContainerData.new(" After killing an enemy, receive 2 stacks of "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.DREAD)

    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.DARKNESS, 4))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.DARKNESS, 4))
    bb_container_data.push_back(BBContainerData.new(" At the start of the first turn receive "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.MADNESS)

    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.DARKNESS, 0))


    if T.is_initialized():
        bb_container_data = Info.get_translated_bb_container_data_arr(ItemSets.DARKNESS.name, "item-set-description", args[1])
        if is_instance_valid(specialization):
            bb_container_data = Info.get_translated_bb_container_data_arr(specialization.name, "specialization-description", args[1])



    return bb_container_data
