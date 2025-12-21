extends BBScript










func get_bb_container_data(args: Array = []) -> Array[BBContainerData]:
    var bb_container_data_arr: Array[BBContainerData] = []

    if args.size() < 2:
        return []

    var stat_resource: StatResource = args[1] as StatResource
    var hover_text: String = T.get_translated_string("Reforge Token Description").to_lower()

    var amount: int = 25
    if not stat_resource.max_amount == -1:
        amount = 10
    hover_text = hover_text.replace("{amount}", str(amount))
    for bb_text in hover_text.split("|"):
        if bb_text == "{stat}":
            bb_container_data_arr.push_back(Stats.get_bb_container_data(stat_resource))
            continue
        bb_container_data_arr.push_back(BBContainerData.new(bb_text))

    return bb_container_data_arr
