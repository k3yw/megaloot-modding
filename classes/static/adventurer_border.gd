class_name AdventurerBorder




enum Type{WOODEN, SILVER, GOLDEN, DEMONIC, JADEN, FROZEN, CELESTIAL, ASCENDED}




static func get_number(type: Type) -> int:

    match type:
        Type.SILVER: return 5
        Type.GOLDEN: return 10
        Type.DEMONIC: return 15
        Type.JADEN: return 20
        Type.FROZEN: return 30
        Type.CELESTIAL: return 60
        Type.ASCENDED: return 100

    return 0



static func get_type(adventurer: Adventurer, floor_number: int) -> Type:
    if not is_instance_valid(adventurer):
        return Type.WOODEN

    var adventurer_name: String = adventurer.name.to_upper()
    var highest_border: int = 0


    if floor_number > 98:
        return Type.ASCENDED

    if floor_number > 58:
        return Type.CELESTIAL

    if floor_number > 28:
        return Type.FROZEN

    if floor_number > 18:
        return Type.JADEN

    if floor_number > 13:
        return Type.DEMONIC

    if floor_number > 8:
        return Type.GOLDEN

    if floor_number > 3:
        return Type.SILVER



    return highest_border as Type




static func get_texture(type: Type) -> Texture2D:
    match type:
        Type.ASCENDED: return preload("res://assets/textures/portrait_borders/ascended_border.png")
        Type.CELESTIAL: return preload("res://assets/textures/portrait_borders/celestial_border.png")
        Type.FROZEN: return preload("res://assets/textures/portrait_borders/frozen_border.png")
        Type.JADEN: return preload("res://assets/textures/portrait_borders/jaden_border.png")
        Type.DEMONIC: return preload("res://assets/textures/portrait_borders/demonic_border.png")
        Type.GOLDEN: return preload("res://assets/textures/portrait_borders/golden_border.png")
        Type.SILVER: return preload("res://assets/textures/portrait_borders/silver_border.png")

    return preload("res://assets/textures/portrait_borders/wooden_border.png")
