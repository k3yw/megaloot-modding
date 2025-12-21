class_name PointTextureRect extends TextureRect







func show_as_full() -> void :
    (texture as AtlasTexture).region.position.x = 0



func show_as_empty() -> void :
    (texture as AtlasTexture).region.position.x = 9
