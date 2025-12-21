class_name ConsumptionEffect extends Resource



@export var stat_to_gain: BonusStat
@export var base_price: float




func get_value(floor_number: int) -> float:
    return base_price + floor_number



func get_bb_container_data(_floor_number: int) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    var text: String = T.get_translated_string("Grants Stat Consumable").to_lower()
    var amount: float = stat_to_gain.amount
    var amount_suffix: String = ""

    if stat_to_gain.resource.is_percentage or stat_to_gain.is_modifier:
        amount_suffix = "%"

    var amount_text: String = "+" + Format.number(amount) + amount_suffix

    text.replace("{amount}", amount_text)


    for bb in text.split("|"):
        if bb == "{stat}":
            bb_container_data.push_back(Stats.get_bb_container_data(stat_to_gain.resource))
            continue
        bb_container_data.push_back(BBContainerData.new(bb, Color.DARK_GRAY))


    return bb_container_data
