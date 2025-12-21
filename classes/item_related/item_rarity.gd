class_name ItemRarity



enum Type{COMMON, UNCOMMON, RARE, LEGENDARY, MYTHIC, ETERNAL, ABYSSAL, COSMIC, DIVINE}



static func get_highest_rarity() -> Type:
    return (Type.size() - 1) as Type



static func get_font_color(rarity: int) -> Color:

    match rarity:
        Type.COMMON: return Color("8b93af")
        Type.UNCOMMON: return Color("#59c135")
        Type.RARE: return Color("#249fde")
        Type.LEGENDARY: return Color("#bc4a9b")
        Type.MYTHIC: return Color("#f9a31b")
        Type.ETERNAL: return Color("#b42045")
        Type.ABYSSAL: return Color("#141013")
        Type.ABYSSAL: return Color("#141013")
        Type.COSMIC: return Color("#060608")
        Type.DIVINE: return Color("#fef3c0")

    return Color.WHITE



static func get_outline_color(rarity: int) -> Color:

    match rarity:
        Type.COMMON: return Color.TRANSPARENT
        Type.UNCOMMON: return Color.TRANSPARENT
        Type.RARE: return Color.TRANSPARENT
        Type.LEGENDARY: return Color.TRANSPARENT
        Type.MYTHIC: return Color.TRANSPARENT
        Type.ETERNAL: return Color.TRANSPARENT
        Type.ABYSSAL: return Color("#73172d")
        Type.COSMIC: return Color("#bc4a9b")
        Type.DIVINE: return Color("#bb7547")

    return Color.TRANSPARENT



static func get_texture(rarity: int) -> Texture2D:

    match rarity:
        Type.COMMON: return preload("res://assets/textures/rarity_borders/common_rarity_border.png")
        Type.UNCOMMON: return preload("res://assets/textures/rarity_borders/uncommon_rarity_border.png")
        Type.RARE: return preload("res://assets/textures/rarity_borders/rare_rarity_border.png")
        Type.LEGENDARY: return preload("res://assets/textures/rarity_borders/legendary_rarity_border.png")
        Type.MYTHIC: return preload("res://assets/textures/rarity_borders/mythic_rarity_border.png")
        Type.ETERNAL: return preload("res://assets/textures/rarity_borders/eternal_rarity_border.png")
        Type.ABYSSAL: return preload("res://assets/textures/rarity_borders/abyssal_rarity_border.png")
        Type.COSMIC: return preload("res://assets/textures/rarity_borders/cosmic_rarity_border.png")
        Type.DIVINE: return preload("res://assets/textures/rarity_borders/divine_rarity_border.png")

    return preload("res://assets/textures/rarity_borders/blank_rarity_border.png")



static func get_hue_texture(rarity: int) -> GradientTexture1D:

    match rarity:
        Type.COMMON: return null
        Type.UNCOMMON: return null
        Type.RARE: return null
        Type.LEGENDARY: return null
        Type.MYTHIC: return null
        Type.ETERNAL: return null
        Type.ABYSSAL: return null
        Type.COSMIC: return preload("res://resources/hues/galaxy_hue.tres")
        Type.DIVINE: return preload("res://resources/hues/divine_hue.tres")

    return null


static func get_hue_strength(rarity: int) -> float:

    match rarity:
        Type.COMMON: return 0
        Type.UNCOMMON: return 0
        Type.RARE: return 0
        Type.LEGENDARY: return 0
        Type.MYTHIC: return 0
        Type.ETERNAL: return 0
        Type.ABYSSAL: return 0
        Type.COSMIC: return 0.35
        Type.DIVINE: return 0.35

    return 0



static func get_shine_alpha(rarity: int) -> float:

    match rarity:
        Type.COMMON: return 0.0
        Type.UNCOMMON: return 0.0
        Type.RARE: return 0.0
        Type.LEGENDARY: return 0.0
        Type.MYTHIC: return 0.0
        Type.ETERNAL: return 0.0
        Type.ABYSSAL: return 0.0
        Type.COSMIC: return 0.0
        Type.DIVINE: return 0.3

    return 0.0
