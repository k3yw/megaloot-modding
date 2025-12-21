extends Node

const PORTRAITS_TEXTURE_PATH: String = "/assets/textures/portraits/"
const ENEMY_TEXTURE_PATH: String = "/assets/textures/enemies/"
const ITEM_TEXTURE_PATH: String = "/assets/textures/items/"









func _ready() -> void :
    var local_portraits_texture_path: String = File.get_file_dir() + "/" + PORTRAITS_TEXTURE_PATH.trim_suffix("/")
    var local_enemy_texture_path: String = File.get_file_dir() + "/" + ENEMY_TEXTURE_PATH.trim_suffix("/")
    var local_item_texture_path: String = File.get_file_dir() + "/" + ITEM_TEXTURE_PATH.trim_suffix("/")

    var portraits_dir = DirAccess.open(local_portraits_texture_path)
    var enemy_dir = DirAccess.open(local_enemy_texture_path)
    var item_dir = DirAccess.open(local_item_texture_path)

    if portraits_dir == null:
        portraits_dir = DirAccess.make_dir_recursive_absolute(local_portraits_texture_path)

    if enemy_dir == null:
        enemy_dir = DirAccess.make_dir_recursive_absolute(local_enemy_texture_path)

    if item_dir == null:
        item_dir = DirAccess.make_dir_recursive_absolute(local_item_texture_path)


    for file_dir in [Adventurers.ADVENTURERS_DIR]:
        for file_name in File.get_file_paths(file_dir):
            var file_path: String = file_dir + file_name
            if ".tres.remap" in file_path:
                file_path = file_path.trim_suffix(".remap")

            var save_path: String = File.get_file_dir() + PORTRAITS_TEXTURE_PATH + file_name.trim_suffix(".tres")
            var resource: Adventurer = load(file_dir + file_name)

            resource.portrait.get_image().save_png(save_path + ".png")
            resource.blink.get_image().save_png(save_path + "_blink.png")


            if FileAccess.file_exists(save_path + "_override.png"):
                resource.portrait = ImageTexture.create_from_image(Image.load_from_file(save_path + "_override.png"))

            if FileAccess.file_exists(save_path + "_blink_override.png"):
                resource.blink = ImageTexture.create_from_image(Image.load_from_file(save_path + "_override.png"))



    for file_dir in [Enemies.ENEMIES_DIR, Enemies.SPECIAL_ENEMIES_DIR]:
        for file_name in File.get_file_paths(file_dir):
            var file_path: String = file_dir + file_name
            if ".tres.remap" in file_path:
                file_path = file_path.trim_suffix(".remap")

            var save_path: String = File.get_file_dir() + ENEMY_TEXTURE_PATH + file_name.trim_suffix(".tres")
            var resource: EnemyResource = load(file_dir + file_name)

            resource.texture.get_image().save_png(save_path + ".png")

            if FileAccess.file_exists(save_path + "_override.png"):
                resource.texture = ImageTexture.create_from_image(Image.load_from_file(save_path + "_override.png"))



    for file_name in File.get_file_paths(Items.ITEMS_DIR):
        var file_path: String = Items.ITEMS_DIR + file_name
        if ".tres.remap" in file_path:
            file_path = file_path.trim_suffix(".remap")

        var save_path: String = File.get_file_dir() + ITEM_TEXTURE_PATH + file_name.trim_suffix(".tres")
        var resource: ItemResource = load(Items.ITEMS_DIR + file_name)

        resource.texture.get_image().save_png(save_path + ".png")

        if FileAccess.file_exists(save_path + "_override.png"):
            resource.texture = ImageTexture.create_from_image(Image.load_from_file(save_path + "_override.png"))



    update_skins()










func update_skins() -> void :
    if OS.get_cmdline_args().has("-hand_of_blood"):
        Adventurers.SID.blink = preload("res://assets/textures/portraits/hanno_blink.png")
        Adventurers.SID.portrait = preload("res://assets/textures/portraits/hanno.png")
        Adventurers.SID.name_override = "Hänno"

    if OS.get_cmdline_args().has("-xqc"):
        Enemies.GOBLIN.texture = preload("res://assets/textures/special_enemies/xqc.png")
        Enemies.GOBLIN.name = "xQc"

    if OS.get_cmdline_args().has("-jesse"):
        Enemies.RED_ORC.texture = preload("res://assets/textures/special_enemies/jesse.png")
        Enemies.RED_ORC.name = "Jesse"
