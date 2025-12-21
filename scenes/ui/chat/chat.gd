@tool
class_name Chat extends MarginContainer

signal text_submitted(submitted_text: String)

@export var scroll_container: GenericScrollContainer
@export var input_line_edit: GenericLineEdit
@export var chat_label: GenericLabel
@export var in_game: bool = false



func _ready() -> void :
    if Engine.is_editor_hint():
        return

    Net.message_received.connect(_on_message_received)

    if in_game:
        return

    Lobby.player_confirmed.connect(_on_lobby_player_confirmed)

    for player in Lobby.data.players:
        if player.name.is_empty():
            continue
        add_player_joined(player.name)

    chat_label.text = T.get_translated_string("Help Command Info").replace("{command}", "/help")
    chat_label.text += "\n"



func _on_lobby_player_confirmed(new_player: int):
    for player in Lobby.data.players:
        if not player.client_id == new_player:
            continue

        add_player_joined(player.name)



func add_player_joined(player_name: String) -> void :
    push_text(player_name + " has joined the lobby")


func _on_message_received(sender_id: int, message: String) -> void :
    for player in Lobby.data.players:
        if player.client_id == sender_id:
            push_text(parse_submitted_text(player.name, message))
            return



func push_text(result: String) -> void :
    chat_label.text += result
    chat_label.text += "\n"


func _on_line_edit_text_submitted(new_text: String) -> void :
    input_line_edit.line_edit.clear()
    push_text(parse_submitted_text(Net.own_name, new_text))

    if not new_text.begins_with("/"):
        Net.call_func(Net.send_message, [Lobby.get_client_id(), new_text])

    text_submitted.emit(new_text)


func parse_submitted_text(sender: String, text: String) -> String:
    match text:
        "/help":
            var kick_info: String = T.get_translated_string("Kick Command Info").to_lower().replace("{command}", "/kick")
            var commands_text: String = T.get_translated_string("Command List").to_lower() + ": "
            return commands_text + kick_info

        _: return sender + ": " + text

    return ""
