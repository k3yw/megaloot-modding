extends Node
class_name MultiplayerClient










































signal connected()




signal connection_failed(error: int)




signal disconnected()




signal client_id_changed(own_id: int)




signal lobby_created(lobby_name: String)






signal lobby_creation_failed(lobby_name: String, error: int)




signal lobby_name_changed(lobby_name: String)






signal lobby_name_change_failed(lobby_name: String, error: int)




signal lobby_joined(lobby_name: String)






signal lobby_join_failed(lobby_name: String, error: int)





signal lobby_data_changed(key: String, value)





signal lobby_tag_changed(key: String, value)





signal client_joined(client_id: int)





signal client_left(client_id: int)





signal player_data_changed(client_id: int, key: String, value)


signal kicked()




signal lobbies_received(lobbies: Array)




signal lobby_received(lobby: Dictionary)









signal host_changed(is_host: bool, new_host_id: int)





signal synced_event_triggered(event_name: String, parameters: Array)




signal change_scene_called(scene_path: String)




signal change_scene_success(scene_path: String)





signal change_scene_failed(scene_path: String)





signal steam_join_request(lobby_name: String, has_password: bool)










var _request_processor
var _connection_controller
var _session_controller
var _https_controller
var _data_controller
var _node_tracker
var _local_server
var _steam
var _logger

func _init():
    _request_processor = preload("res://addons/GD-Sync/Scripts/RequestProcessor.gd").new()
    _connection_controller = preload("res://addons/GD-Sync/Scripts/ConnectionController.gd").new()
    _session_controller = preload("res://addons/GD-Sync/Scripts/SessionController.gd").new()
    _https_controller = preload("res://addons/GD-Sync/Scripts/HTTPSController.gd").new()
    _data_controller = preload("res://addons/GD-Sync/Scripts/DataController.gd").new()
    _node_tracker = preload("res://addons/GD-Sync/Scripts/NodeTracker.gd").new()
    _local_server = preload("res://addons/GD-Sync/Scripts/LocalServer.gd").new()
    _steam = preload("res://addons/GD-Sync/Scripts/Steam.gd").new()
    _logger = preload("res://addons/GD-Sync/Scripts/Logger.gd").new()

func _ready():
    add_child(_request_processor)
    add_child(_connection_controller)
    add_child(_session_controller)
    add_child(_https_controller)
    add_child(_data_controller)
    add_child(_node_tracker)
    add_child(_local_server)
    add_child(_steam)
    add_child(_logger)

















func start_multiplayer() -> void :
    _connection_controller.start_multiplayer()




func quit() -> void :
    _data_controller.quit()







func start_local_multiplayer() -> void :
    _connection_controller.start_local_multiplayer()


func stop_multiplayer() -> void :
    _connection_controller.stop_multiplayer()


func is_active() -> bool:
    return _connection_controller.is_active()

func _manual_connect(address: String) -> void :
    _connection_controller.connect_to_server(address)


func get_client_id() -> int:
    return _connection_controller.client_id



func get_client_ping(client_id: int) -> float:
    return await _session_controller.get_ping(client_id)






func get_sender_id() -> int:
    return _session_controller.get_sender_id()


func is_host() -> bool:
    return _connection_controller.host == get_client_id()


func get_host() -> int:
    return _connection_controller.host




func set_host(client_id: int) -> void :
    _request_processor.create_set_host_request(client_id)










func sync_var(object: Object, variable_name: String, reliable: bool = true) -> void :
    _request_processor.create_set_var_request(object, variable_name, -1, reliable)











func sync_var_on(client_id: int, object: Object, variable_name: String, reliable: bool = true) -> void :
    _request_processor.create_set_var_request(object, variable_name, client_id, reliable)










func call_func(callable: Callable, parameters: Array = [], reliable: bool = true) -> void :
    _request_processor.create_function_call_request(callable, parameters, -1, reliable)











func call_func_on(client_id: int, callable: Callable, parameters: Array = [], reliable: bool = true) -> void :
    _request_processor.create_function_call_request(callable, parameters, client_id, reliable)










func call_func_all(callable: Callable, parameters: Array = [], reliable: bool = true) -> void :
    callable.call(parameters)
    _request_processor.create_function_call_request(callable, parameters, -1, reliable)












func multiplayer_instantiate(
        scene: PackedScene, 
        parent: Node, 
        sync_starting_changes: bool = true, 
        excluded_properties: PackedStringArray = [], 
        replicate_on_join: bool = true) -> Node:
    return _node_tracker.multiplayer_instantiate(scene, parent, sync_starting_changes, excluded_properties, replicate_on_join)

func multiplayer_queue_free(node: Node) -> void :
    _node_tracker.multiplayer_queue_free(node)






func get_multiplayer_time() -> float:
    return _session_controller.synced_time











func synced_event_create(event_name: String, delay: float = 1.0, parameters: Array = []) -> void :
    _session_controller.register_event(event_name, get_multiplayer_time() + delay, parameters, true)






func change_scene(scene_path: String) -> void :
    _session_controller.change_scene(scene_path)





















func set_protection_mode(protected: bool) -> void :
    _request_processor.set_protection_mode(protected)





func register_resource(resource: Resource, id: String) -> void :
    _session_controller.create_resource_reference(resource, id)




func deregister_resource(resource: Resource) -> void :
    _session_controller.erase_resource_reference(resource)







func expose_node(node: Node) -> void :
    _session_controller.expose_object(node)







func hide_node(node: Node) -> void :
    _session_controller.hide_object(node)







func expose_resource(resource: Resource) -> void :
    _session_controller.expose_object(resource)







func hide_resource(resource: Resource) -> void :
    _session_controller.hide_object(resource)






func expose_func(callable: Callable) -> void :
    _session_controller.expose_func(callable)






func hide_function(callable: Callable) -> void :
    _session_controller.hide_function(callable)







func expose_var(object: Object, variable_name: String) -> void :
    _session_controller.expose_property(object, variable_name)







func hide_var(object: Object, variable_name: String) -> void :
    _session_controller.hide_property(object, variable_name)

























func set_gdsync_owner(node: Node, owner: int) -> void :
    if !_connection_controller.valid_connection(): return
    _session_controller.set_gdsync_owner(node, owner)






func clear_gdsync_owner(node: Node) -> void :
    if !_connection_controller.valid_connection(): return
    _session_controller.set_gdsync_owner(node, -1)




func get_gdsync_owner(node: Node) -> int:
    return _session_controller.get_gdsync_owner(node)




func is_gdsync_owner(node: Node) -> bool:
    return _session_controller.is_gdsync_owner(node)







func connect_gdsync_owner_changed(node: Node, callable: Callable) -> void :
    _session_controller.connect_gdsync_owner_changed(node, callable)






func disconnect_gdsync_owner_changed(node: Node, callable: Callable) -> void :
    _session_controller.disconnect_gdsync_owner_changed(node, callable)

















func get_public_lobbies() -> void :
    if !_connection_controller.valid_connection(): return
    if _connection_controller.is_local():
        _local_server.get_public_lobbies()
    else:
        _request_processor.get_public_lobbies()





func get_public_lobby(lobby_name: String) -> void :
    if !_connection_controller.valid_connection(): return
    if _connection_controller.is_local():
        _local_server.get_public_lobby(lobby_name)
    else:
        _request_processor.get_public_lobby(lobby_name)












func lobby_create(name: String, password: String = "", public: bool = true, player_limit: int = 0, tags: Dictionary = {}, data: Dictionary = {}) -> void :
    if !_connection_controller.valid_connection(): return
    if _connection_controller.is_local():
        _local_server.create_local_lobby(name, password, public, player_limit, tags, data)
    else:
        _request_processor.create_new_lobby_request(name, password, public, player_limit, tags, data)








func lobby_join(name: String, password: String = "") -> void :
    if !_connection_controller.valid_connection(): return
    _session_controller.set_lobby_data(name, password)
    if _connection_controller.is_local():
        _local_server.join_lobby(name, password)
    else:
        _request_processor.create_join_lobby_request(name, password)


func lobby_close() -> void :
    if !_connection_controller.valid_connection(): return
    _request_processor.create_close_lobby_request()


func lobby_open() -> void :
    if !_connection_controller.valid_connection(): return
    _request_processor.create_open_lobby_request()




func lobby_set_visibility(public: bool) -> void :
    if !_connection_controller.valid_connection(): return
    _request_processor.create_lobby_visiblity_request(public)





func lobby_change_name(name: String) -> void :
    _request_processor.create_lobby_name_change_request(name)




func lobby_change_password(password: String) -> void :
    if !_connection_controller.valid_connection(): return
    _request_processor.create_change_lobby_password_request(password)


func lobby_leave() -> void :
    if !_connection_controller.valid_connection(): return
    _request_processor.create_leave_lobby_request()
    _data_controller.set_friend_status()
    _session_controller.lobby_left()
    _node_tracker.lobby_left()
    _steam.leave_steam_lobby()




func lobby_kick_client(client_id: int) -> void :
    if !_connection_controller.valid_connection(): return
    _request_processor.kick_player(client_id)


func lobby_get_all_clients() -> Array:
    return _session_controller.get_all_clients()


func lobby_get_player_count() -> int:
    return _session_controller.get_all_clients().size()


func lobby_get_name() -> String:
    return GDSync._session_controller.lobby_name


func lobby_get_player_limit() -> int:
    return _session_controller.get_player_limit()


func lobby_has_password() -> bool:
    return _session_controller.lobby_has_password()










func lobby_set_tag(key: String, value) -> void :
    if !_connection_controller.valid_connection(): return
    _request_processor.create_set_lobby_tag_request(key, value)








func lobby_erase_tag(key: String) -> void :
    if !_connection_controller.valid_connection(): return
    _request_processor.create_erase_lobby_tag_request(key)




func lobby_has_tag(key: String) -> bool:
    return _session_controller.has_lobby_tag(key)





func lobby_get_tag(key: String, default = null):
    return _session_controller.get_lobby_tag(key, default)


func lobby_get_all_tags() -> Dictionary:
    return _session_controller.get_all_lobby_tags()









func lobby_set_data(key: String, value) -> void :
    if !_connection_controller.valid_connection(): return
    _request_processor.create_set_lobby_data_request(key, value)








func lobby_erase_data(key: String) -> void :
    if !_connection_controller.valid_connection(): return
    _request_processor.create_erase_lobby_data_request(key)




func lobby_has_data(key: String) -> bool:
    return _session_controller.has_lobby_data(key)





func lobby_get_data(key: String, default = null):
    return _session_controller.get_lobby_data(key, default)


func lobby_get_all_data() -> Dictionary:
    return _session_controller.get_all_lobby_data()




















func player_set_data(key: String, value) -> void :
    if !_connection_controller.valid_connection(): return
    _session_controller.set_player_data(key, value)
    _request_processor.create_set_player_data_request(key, value)





func player_erase_data(key: String) -> void :
    if !_connection_controller.valid_connection(): return
    _session_controller.erase_player_data(key)
    _request_processor.create_erase_player_data_request(key)







func player_get_data(client_id: int, key: String, default = null):
    if !_connection_controller.valid_connection(): return default
    return _session_controller.get_player_data(client_id, key, default)





func player_get_all_data(client_id: int) -> Dictionary:
    if !_connection_controller.valid_connection(): return {}
    return _session_controller.get_all_player_data(client_id)






func player_set_username(name: String) -> void :
    _request_processor.create_set_username_request(name)
    _session_controller.set_player_data("Username", name)




















func account_create(email: String, username: String, password: String) -> int:
    if _connection_controller.is_local_check(): return 1
    return await _data_controller.create_account(email, username, password)






func account_delete(email: String, password: String) -> int:
    if _connection_controller.is_local_check(): return 1
    return await _data_controller.delete_account(email, password)









func account_verify(email: String, code: String, valid_time: float = 86400) -> int:
    if _connection_controller.is_local_check(): return 1
    return await _data_controller.verify_account(email, code, valid_time)







func account_resend_verification_code(email: String, password: String) -> int:
    if _connection_controller.is_local_check(): return 1
    return await _data_controller.resend_verification_code(email, password)











func account_is_verified(username: String = "") -> Dictionary:
    if _connection_controller.is_local_check(): return {"Code": 1}
    return await _data_controller.is_verified(username)

















func account_login(email: String, password: String, valid_time: float = 86400) -> Dictionary:
    if _connection_controller.is_local_check(): return {"Code": 1}
    return await _data_controller.login(email, password, valid_time)






func account_login_from_session(valid_time: float = 86400) -> int:
    if _connection_controller.is_local_check(): return 1
    return await _data_controller.login_from_session(valid_time)



func account_logout() -> int:
    if _connection_controller.is_local_check(): return 1
    return await _data_controller.logout()





func account_ban(ban_duration: float) -> int:
    if _connection_controller.is_local_check(): return 1
    return await _data_controller.ban_account(ban_duration)





func account_change_username(new_username: String) -> int:
    if _connection_controller.is_local_check(): return 1
    return await _data_controller.change_username(new_username)







func account_change_password(email: String, password: String, new_password: String) -> int:
    if _connection_controller.is_local_check(): return 1
    return await _data_controller.change_password(email, password, new_password)





func account_request_password_reset(email: String) -> int:
    if _connection_controller.is_local_check(): return 1
    return await _data_controller.request_password_reset(email)






func account_reset_password(email: String, reset_code: String, new_password: String) -> int:
    if _connection_controller.is_local_check(): return 1
    return await _data_controller.reset_password(email, reset_code, new_password)






func account_create_report(username_to_report: String, report: String) -> int:
    if _connection_controller.is_local_check(): return 1
    return await _data_controller.report_user(username_to_report, report)





func account_send_friend_request(friend: String) -> int:
    if _connection_controller.is_local_check(): return 1
    return await _data_controller.send_friend_request(friend)





func account_accept_friend_request(friend: String) -> int:
    if _connection_controller.is_local_check(): return 1
    return await _data_controller.accept_friend_request(friend)





func account_remove_friend(friend: String) -> int:
    if _connection_controller.is_local_check(): return 1
    return await _data_controller.remove_friend(friend)



















func account_get_friend_status(friend: String) -> Dictionary:
    if _connection_controller.is_local_check(): return {"Code": 1}
    return await _data_controller.account_get_friend_status(friend)


































func account_get_friends() -> Dictionary:
    if _connection_controller.is_local_check(): return {"Code": 1}
    return await _data_controller.get_friends()













func account_document_set(path: String, document: Dictionary, externally_visible: bool = false) -> int:
    if _connection_controller.is_local_check(): return 1
    return await _data_controller.set_player_document(path, document, externally_visible)









func account_document_set_external_visible(path: String, externally_visible: bool = false) -> int:
    if _connection_controller.is_local_check(): return 1
    return await _data_controller.set_external_visible(path, externally_visible)











func account_get_document(path: String) -> Dictionary:
    if _connection_controller.is_local_check(): return {"Code": 1}
    return await _data_controller.get_player_document(path, "")











func account_has_document(path: String) -> Dictionary:
    if _connection_controller.is_local_check(): return {"Code": 1}
    return await _data_controller.has_player_document(path, "")

















func account_browse_collection(path: String) -> Dictionary:
    if _connection_controller.is_local_check(): return {"Code": 1}
    return await _data_controller.browse_player_collection(path, "")





func account_delete_document(path: String) -> int:
    if _connection_controller.is_local_check(): return 1
    return await _data_controller.delete_player_document(path)












func account_get_external_document(external_username: String, path: String) -> Dictionary:
    if _connection_controller.is_local_check(): return {"Code": 1}
    return await _data_controller.get_player_document(path, external_username)












func account_has_external_document(external_username: String, path: String) -> Dictionary:
    if _connection_controller.is_local_check(): return {"Code": 1}
    return await _data_controller.has_player_document(path, external_username)


















func account_browse_external_collection(external_username: String, path: String) -> Dictionary:
    if _connection_controller.is_local_check(): return {"Code": 1}
    return await _data_controller.browse_player_collection(path, external_username)











func leaderboard_exists(leaderboard: String) -> Dictionary:
    if _connection_controller.is_local_check(): return {"Code": 1}
    return await _data_controller.has_leaderboard(leaderboard)















func leaderboard_get_all() -> Dictionary:
    if _connection_controller.is_local_check(): return {"Code": 1}
    return await _data_controller.get_leaderboards()




















func leaderboard_browse_scores(leaderboard: String, page_size: int, page: int) -> Dictionary:
    if _connection_controller.is_local_check(): return {"Code": 1}
    return await _data_controller.browse_leaderboard(leaderboard, page_size, page)

















func leaderboard_get_score(leaderboard: String, username: String) -> Dictionary:
    if _connection_controller.is_local_check(): return {"Code": 1}
    return await _data_controller.get_leaderboard_score(leaderboard, username)







func leaderboard_submit_score(leaderboard: String, score: int) -> int:
    if _connection_controller.is_local_check(): return 1
    return await _data_controller.submit_score(leaderboard, score)





func leaderboard_delete_score(leaderboard: String) -> int:
    if _connection_controller.is_local_check(): return 1
    return await _data_controller.delete_score(leaderboard)
















func steam_integration_enabled() -> bool:
    return _steam.steam_integration_enabled




func steam_link_account() -> int:
    return await _steam.link_steam_account()



func steam_unlink_account() -> int:
    return await _steam.unlink_steam_account()
















func steam_login(valid_time: float = 86400) -> Dictionary:
    return await _steam.steam_login(valid_time)
