class_name PingTextureRect extends TextureRect



@export var hover_info_module: HoverInfoModule




func _ready() -> void :
    visible = Lobby.data.players.size() > 1



func _process(_delta: float) -> void :
    var ping: int = Net.ping
    hover_info_module.data = [ping]

    (texture as AtlasTexture).region.position.x = 0

    if ping > 100:
        (texture as AtlasTexture).region.position.x = 8

    if ping > 200:
        (texture as AtlasTexture).region.position.x = 16
