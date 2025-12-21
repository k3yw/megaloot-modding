class_name ImageSelectionContainer extends MarginContainer


@export var selection_border: NinePatchRect
@export var image_texture_rect: TextureRect
@export var misc_label: GenericLabel
@export var file_dialog: FileDialog

var selected_image_path: String = ""
var hovering: bool = false




func _process(_delta: float) -> void :
    hovering = UI.is_hovered(self)
    selection_border.visible = hovering

    if hovering and Input.is_action_just_pressed("press"):
        file_dialog.show()

    misc_label.visible = not is_instance_valid(image_texture_rect.texture)




func _on_file_dialog_file_selected(path: String) -> void :
    selected_image_path = path

    var image = Image.load_from_file(path)
    var texture = ImageTexture.create_from_image(image)
    image_texture_rect.texture = texture
