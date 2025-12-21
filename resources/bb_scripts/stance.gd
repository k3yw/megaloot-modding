extends BBScript










func get_bb_container_data(args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []
    var owner_name: String = args[0] as String
    var character: Character = null
    var reduction: float = 0.0

    if args.size() > 1:
        character = args[1] as Character
        reduction = character.get_guard_reduction()

    if not T.is_initialized():
        return bb_container_data


    var stance_text: String = T.get_translated_string("skip-stance")
    if reduction > 0.0:
        stance_text = T.get_translated_string("guard-stance")
        stance_text = stance_text.replace("{amount}", "%0.0f" % (reduction * 100))

    bb_container_data.push_back(BBContainerData.new(stance_text, Color.DIM_GRAY))




    return bb_container_data
