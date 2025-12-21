extends BBScript











func get_bb_container_data(args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []
    var specialization: Specialization = args[0] as Specialization

    match specialization:
        Specializations.HARBINGER:
            bb_container_data.push_back(BBContainerData.new("<.>"))
            bb_container_data.push_back(BBContainerData.new(" Deal +1000% attack damage to enemies with ", Color.DARK_GRAY))
            bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.ARTHURS_MARK)
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("\n"))

        Specializations.LIONHEART:
            bb_container_data.push_back(BBContainerData.new("<.>"))
            bb_container_data.push_back(BBContainerData.new(" Reduce damage by 1000% from enemies with ", Color.DARK_GRAY))
            bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.ARTHURS_MARK)
            bb_container_data.push_back(BBContainerData.new("\n"))
            bb_container_data.push_back(BBContainerData.new("\n"))


    bb_container_data.push_back(BBContainerData.new("<.>"))
    bb_container_data.push_back(BBContainerData.new(" At the start of the battle, receive ", Color.DARK_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.INVULNERABILITY)
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("\n"))

    bb_container_data.push_back(BBContainerData.new("<.>"))
    bb_container_data.push_back(BBContainerData.new(" At the end of your first turn, apply a stack", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("  of ", Color.DARK_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.ARTHURS_MARK)
    bb_container_data.push_back(BBContainerData.new(" on a random enemy", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("\n"))

    bb_container_data.push_back(BBContainerData.new("<.>"))
    bb_container_data.push_back(BBContainerData.new(" When an enemy with ", Color.DARK_GRAY))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.ARTHURS_MARK)
    bb_container_data.push_back(BBContainerData.new(" dies,", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("  it will be applied on another enemy", Color.DARK_GRAY))


    return bb_container_data
