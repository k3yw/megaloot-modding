extends SubViewport


@export var adventurer_texture_rect: TextureRect
@export var border_texture_rect: TextureRect


func _ready() -> void :
    for adventurer in Adventurers.LIST:
        for border in AdventurerBorder.Type.values():
            var file_name: String = adventurer.name.to_lower() + "_" + (AdventurerBorder.Type.keys()[border] as String).to_lower() + ".png"
            adventurer_texture_rect.texture = adventurer.portrait
            border_texture_rect.texture = AdventurerBorder.get_texture(border)

            await RenderingServer.frame_post_draw

            get_texture().get_image().save_png("user://" + file_name)
