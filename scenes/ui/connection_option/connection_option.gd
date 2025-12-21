class_name ConnectionOption extends HBoxContainer


@export var status_texture_tect: TextureRect
@export var line_edit: GenericLineEdit
@export var loading_animation: Control


func _ready() -> void :
    set_connection_status(ConnectionStatus.Type.DISCONNECTED)


func set_connection_status(status: ConnectionStatus.Type) -> void :
    match status:
        ConnectionStatus.Type.CONNECTED:
            (status_texture_tect.texture as AtlasTexture).region.position.x = 0
            status_texture_tect.show()
            loading_animation.hide()

        ConnectionStatus.Type.DISCONNECTED:
            (status_texture_tect.texture as AtlasTexture).region.position.x = 9
            status_texture_tect.show()
            loading_animation.hide()

        ConnectionStatus.Type.CONNECTING:
            status_texture_tect.hide()
            loading_animation.show()
