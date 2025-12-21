extends BBScript












func get_bb_container_data(args: Array = []) -> Array[BBContainerData]:
    var specialization: Specialization = args[0] as Specialization
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.CHROMALURE, 1))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.CHROMALURE, 1))

    bb_container_data.push_back(BBContainerData.new(" After applying "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.POISON)
    bb_container_data.push_back(BBContainerData.new(", deal "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.POISON_DAMAGE))
    bb_container_data.push_back(BBContainerData.new(" that"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("  equals to that amount to the target"))

    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("\n"))

    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.CHROMALURE, 3))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.CHROMALURE, 3))
    bb_container_data.push_back(BBContainerData.new(" At the start of every turn, recieve "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.TOXIC_TRANSMUTE)



    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.CHROMALURE, 0))
    match specialization:
        Specializations.CHROMASPITE:
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("<.>"))
            bb_container_data.push_back(BBContainerData.new(" Convert 75% of your "))
            bb_container_data.push_back(Stats.get_bb_container_data(Stats.PHYSICAL_ATTACK))
            bb_container_data.push_back(BBContainerData.new(" to"))
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new(" "))
            bb_container_data.push_back(Stats.get_bb_container_data(Stats.TOXICITY))


    return bb_container_data
