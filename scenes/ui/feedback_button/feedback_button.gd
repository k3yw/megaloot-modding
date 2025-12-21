@tool
class_name FeedbackButton extends GenericButton











func _process(delta: float) -> void :
    super._process(delta)

    if not is_pressed:
        return

    OS.shell_open("https://vent.axilirate.com/discord")
