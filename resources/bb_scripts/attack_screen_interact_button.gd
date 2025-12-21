extends BBScript










func get_bb_container_data(args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []
    var character: Character = null

    if args.size() > 1:
        character = args[1] as Character


    return bb_container_data
