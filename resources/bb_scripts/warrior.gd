extends BBScript










func get_bb_container_data(args: Array = []) -> Array[BBContainerData]:
    var specialization: Specialization = args[0] as Specialization
    var bb_container_data: Array[BBContainerData] = []


    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.WARRIOR, 1))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.WARRIOR, 1))

    bb_container_data.push_back(BBContainerData.new(" Every time you attack, receive "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.COMBAT_INSIGHT)

    bb_container_data.push_back(BBContainerData.new("\n"))

    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.WARRIOR, 4))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.WARRIOR, 4))

    bb_container_data.push_back(BBContainerData.new(" When you get attacked, receive "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.COMBAT_INSIGHT)



    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.WARRIOR, 0))

    match specialization:
        Specializations.THUNDERBORN:
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("<.>"))
            bb_container_data.push_back(BBContainerData.new(" Everytime you stun an enemy, attack it"))

        Specializations.QUICKBLADE:
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("<.>"))
            bb_container_data.push_back(BBContainerData.new("  Every time you "))
            bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.PARRY))
            bb_container_data.push_back(BBContainerData.new(", receive +1 "))
            bb_container_data.push_back(Stats.get_bb_container_data(Stats.TOTAL_ATTACKS))
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("   resets every battle", Color.DIM_GRAY))


    return bb_container_data
