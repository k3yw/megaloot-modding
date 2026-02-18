class_name WorkshopState extends Node

const STEAM_WORKSHOP_AGREEMENT_URL: String = "https://steamcommunity.com/sharedfiles/workshoplegalagreement"

@export var active_mods_label_container: VBoxContainer

@export var image_selection_container: ImageSelectionContainer
@export var select_file_button: GenericButton
@export var file_dialog: FileDialog

@export var workshop_id_line_edit: LineEdit
@export var file_path_line_edit: LineEdit
@export var name_line_edit: LineEdit

@export var update_upload_button: GenericButton

@export var back_button: GenericButton







func _ready() -> void :
    Steam.item_created.connect(_on_item_created)
    Steam.item_updated.connect(_on_item_updated)

    select_file_button.pressed.connect( func():
        file_dialog.show()
        )


    update_upload_button.pressed.connect( func():
        if workshop_id_line_edit.text.length() > 0:
            update_workshop_item(int(workshop_id_line_edit.text), false)
            return

        Steam.createItem(Platform.get_app_id(), Steam.WORKSHOP_FILE_TYPE_COMMUNITY)
        )

    for active_mod in Workshop.active_mods:
        var mod_label: GenericLabel = preload("res://scenes/ui/generic_label/generic_label.tscn").instantiate()
        mod_label.text = active_mod.trim_suffix(".pck")
        active_mods_label_container.add_child(mod_label)



func _process(_delta: float) -> void :
    update_update_upload_button()



func _on_item_created(result: int, file_id: int, need_to_accept_tos: bool) -> void :
    if result == 1:
        print("Workshop item created successfully: ", file_id)
    else:
        print("Workshop item could not be created.")

    if need_to_accept_tos:
        Steam.activateGameOverlayToWebPage(STEAM_WORKSHOP_AGREEMENT_URL)

    update_workshop_item(file_id, true)



func _on_item_updated(result: int, need_to_accept_tos: bool) -> void :
    if need_to_accept_tos:
        Steam.activateGameOverlayToWebPage(STEAM_WORKSHOP_AGREEMENT_URL)

    if not result == 1:
        print("Item upload has failed. error: ", result)
        return

    print("Item successfully uploaded.")




func update_workshop_item(file_id: int, new: bool) -> void :
    print("Uploading workshop item with ID %s..." % file_id)
    var update_handle = Steam.startItemUpdate(Platform.get_app_id(), file_id)
    var file_name: String = name_line_edit.text

    if file_name.is_empty() and new:
        file_name = "Megaloot Mod"

    if not file_name.is_empty():
        Steam.setItemTitle(update_handle, file_name)

    if not image_selection_container.selected_image_path.is_empty():
        Steam.setItemPreview(update_handle, image_selection_container.selected_image_path)



    var set_item_content_result: bool = Steam.setItemContent(update_handle, file_path_line_edit.text)
    print("Set item content result: ", set_item_content_result)

    Steam.submitItemUpdate(update_handle, "")
    image_selection_container.image_texture_rect.texture = null
    image_selection_container.selected_image_path = ""
    file_path_line_edit.text = ""



func update_update_upload_button() -> void :
    update_upload_button.text = T.get_translated_string("upload").to_upper()
    if workshop_id_line_edit.text.length() > 0:
        update_upload_button.text = T.get_translated_string("update").to_upper()
    update_upload_button.disabled = file_path_line_edit.text.is_empty()



func _on_file_dialog_file_selected(path: String) -> void :
    file_path_line_edit.text = path


func _on_file_dialog_dir_selected(dir: String) -> void :
    file_path_line_edit.text = dir
