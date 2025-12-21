@tool
class_name SteamButton extends GenericButton







func _process(delta: float) -> void :
    if Engine.is_editor_hint():
        return

    super._process(delta)

    if is_pressed:
        OS.shell_open("https://vent.axilirate.com/divine_+_steam")
