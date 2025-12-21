class_name SpeedrunOption extends ConnectionOption





func _ready() -> void :
    OptionsManager.options_loaded.connect(_on_options_loaded)
    Net.speedrun_auth_updated.connect(_on_speedrun_auth_updated)
    line_edit.changed.connect(_on_line_edit_changed)
    super._ready()


func _on_options_loaded():
    line_edit.line_edit.text = OptionsManager.options.speedrun_api_key


func _on_speedrun_auth_updated() -> void :
    set_connection_status(Net.speedrun_auth.connection_status)



func _on_line_edit_changed() -> void :
    OptionsManager.set_speedrun_api_key(line_edit.line_edit.text)
    if line_edit.line_edit.text.length() == Net.SPEEDRUN_API_KEY_LENGTH:
        Net.send_speedrun_authentication_request(line_edit.line_edit.text)
        return

    Net.disconnect_speedrun()
