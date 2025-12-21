extends Node

signal message_received(sender_id: int, message: String)

signal speedrun_auth_updated

const MAX_PACKET_SIZE: int = 1000
const DEFAULT_PORT: int = 24403


const SPEEDRUN_API_KEY_LENGTH: int = 25

var speedrun_auth: SpeedrunAuth = SpeedrunAuth.new()
var own_name: String = ""

var received_chunks: Dictionary = {}
var packet_id_counter: int = -1

var gd_sync_connection_locked: bool = false
var ping_history: Array[int] = []
var ping: int



class SpeedrunAuth extends Object:
    var connection_status: ConnectionStatus.Type = ConnectionStatus.Type.DISCONNECTED
    var user_name: String
    var id: String




func _ready() -> void :
    process_mode = ProcessMode.PROCESS_MODE_ALWAYS

    if ISteam.is_active():
        ISteam.steam.p2p_session_connect_fail.connect(_on_p2p_session_connect_fail)
        ISteam.steam.p2p_session_request.connect(_on_p2p_session_request)

    GDSync.connection_failed.connect(_on_gd_sync_connection_failed)
    GDSync.disconnected.connect(_on_gd_sync_disconnected)
    GDSync.connected.connect(_on_gd_sync_connected)

    GDSync.expose_func(_ping_response)
    GDSync.expose_func(_ping_request)
    GDSync.expose_func(send_message)
    GDSync.expose_func(receive_func)

    own_name = UserData.profile.get_name()

    GDSync.start_multiplayer()




func _on_p2p_session_connect_fail(remote_steam_id: int, session_error: int) -> void :
    print("P2P session failed with: ", remote_steam_id, " : ", session_error)


func _on_p2p_session_request(remote_steam_id: int) -> void :
    if Lobby.data.steam_lobby_id == -1:
        return

    for idx in ISteam.steam.getNumLobbyMembers(Lobby.data.steam_lobby_id):
        var memeber: int = ISteam.steam.getLobbyMemberByIndex(Lobby.data.steam_lobby_id, idx)
        if memeber == remote_steam_id:
            ISteam.steam.acceptP2PSessionWithUser(remote_steam_id)
            print("Accepting P2P session with: ", memeber)





func _on_gd_sync_connection_failed(error: int) -> void :
    print("GD Sync connection failed: ", error)
    if GDSync.is_active():
        return
    try_to_reconnect()


func _on_gd_sync_disconnected() -> void :
    print("GD Sync connection failed")
    try_to_reconnect()


func _on_gd_sync_connected() -> void :
    print("connected to gd sync!")



func try_to_reconnect():
    if gd_sync_connection_locked == true:
        gd_sync_connection_locked = false
        await get_tree().create_timer(1).timeout
        GDSync.start_multiplayer()
        return

    gd_sync_connection_locked = true
    print("trying to reconnect")
    GDSync.stop_multiplayer()
    try_to_reconnect()




func send_speedrun_authentication_request(api_key: String) -> void :
    var api_url: String = "https://www.speedrun.com/api/v1/profile"
    var headers: PackedStringArray = ["X-API-Key: " + api_key]

    speedrun_auth.connection_status = ConnectionStatus.Type.CONNECTING
    speedrun_auth_updated.emit()

    HTTP.send_request(api_url, headers, func(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
        var json = JSON.parse_string(body.get_string_from_utf8())
        if json and "data" in json:
            speedrun_auth.connection_status = ConnectionStatus.Type.CONNECTED
            speedrun_auth.user_name = json["data"]["names"]["international"]
            speedrun_auth.id = json["data"]["id"]

            speedrun_auth_updated.emit()
            return

        print("Failed to parse authentication JSON")
    )



func disconnect_speedrun() -> void :
    speedrun_auth.connection_status = ConnectionStatus.Type.DISCONNECTED
    speedrun_auth_updated.emit()




func send_message(sender_id: int, message: String) -> void :
    message_received.emit(sender_id, message)




func call_func(callable: Callable, data: Array, peers: PackedInt64Array = []) -> void :
    var node: Node = callable.get_object()
    var callable_data: Dictionary = {
        "node_path": String(node.get_path()), 
        "function_name": callable.get_method()
    }
    var packed_data: PackedByteArray = var_to_bytes([callable_data, data]).compress(FileAccess.COMPRESSION_GZIP)
    var total_size: int = packed_data.size()
    var chunk_count: int = ceili(float(total_size) / MAX_PACKET_SIZE)

    packet_id_counter += 1

    var curr_packet_id: String = str(Lobby.get_client_id()) + ":" + str(packet_id_counter)


    for idx in range(chunk_count):
        var start_index = idx * MAX_PACKET_SIZE
        var end_index = min((idx + 1) * MAX_PACKET_SIZE, total_size)
        var chunk: Array = packed_data.slice(start_index, end_index)
        var packet: Array = [curr_packet_id, total_size, chunk]

        var packet_bytes = var_to_bytes(packet)

        match Lobby.data.type:
            Lobby.Type.GD_SYNC:
                if peers.is_empty():
                    GDSync.call_func(receive_func, [packet_bytes])
                for peer in peers:
                    GDSync.call_func_on(peer, receive_func, [packet_bytes])


            Lobby.Type.STEAM:
                if peers.is_empty():
                    for peer_idx in ISteam.steam.getNumLobbyMembers(Lobby.data.steam_lobby_id):
                        var memeber: int = ISteam.steam.getLobbyMemberByIndex(Lobby.data.steam_lobby_id, peer_idx)
                        ISteam.steam.sendP2PPacket(memeber, packet_bytes, ISteam.steam.P2P_SEND_RELIABLE)

                for peer in peers:
                    ISteam.steam.sendP2PPacket(peer, packet_bytes, ISteam.steam.P2P_SEND_RELIABLE)


            Lobby.Type.MANUAL:
                if peers.is_empty():
                    receive_func.rpc(packet_bytes)

                for peer in peers:
                    receive_func.rpc_id(peer, packet_bytes)



        await get_tree().process_frame





@rpc("any_peer", "reliable", "call_remote")
func receive_func(packet_bytes: PackedByteArray) -> void :
    var packet = bytes_to_var(packet_bytes)


    if not packet is Array:
        print("packet is not an array")
        return
    packet = packet as Array

    var packet_id: String = packet[0]
    var total_size: int = packet[1]
    var data_chunk: Array = packet[2]

    if not received_chunks.has(packet_id):
        received_chunks[packet_id] = []

    (received_chunks[packet_id] as Array).append_array(data_chunk)

    var result: PackedByteArray = PackedByteArray(received_chunks[packet_id])


    if result.size() == total_size:
        process_func(result.decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP))
        received_chunks.erase(packet_id)



func process_func(full_data: PackedByteArray) -> void :
    var data = bytes_to_var(full_data)
    if data == null or not data is Array:
        print("recieved invalid data: ", data)
        return

    var callable_data: Dictionary = data[0]


    if not GDSync._session_controller.function_is_exposed(get_node(callable_data["node_path"]), callable_data["function_name"]):
        return

    get_node_or_null(callable_data["node_path"]).callv(callable_data["function_name"], data[1])





func _ping_request(sender_id: int, time: int) -> void :
    Net.call_func(_ping_response, [time], [sender_id])



func _ping_response(time: int) -> void :
    ping_history.push_front(Time.get_ticks_msec() - time)

    if ping_history.size() > 10:
        ping_history.pop_back()

    var total: int = 0
    for p in ping_history:
        total += p

    var p: float = float(total) / ping_history.size()
    ping = roundi(p / 2)




func _on_ping_request_timer_timeout() -> void :
    if Lobby.is_lobby_owner():
        return

    if Lobby.get_lobby_player_count() <= 1:
        return

    Net.call_func(_ping_request, [Lobby.get_client_id(), Time.get_ticks_msec()], [Lobby.get_host()])



func _process(_delta: float) -> void :
    if not ISteam.is_active():
        return

    if not ISteam.steam.loggedOn():
        return

    ISteam.steam.run_callbacks()

    if not Lobby.data.steam_lobby_id == -1:
        read_all_p2p_packets()



func read_all_p2p_packets() -> void :
    var packet_size: int = ISteam.steam.getAvailableP2PPacketSize(0)

    while packet_size > 0:
        var packet: Dictionary = ISteam.steam.readP2PPacket(packet_size, 0)

        if packet.is_empty() or packet == null:
            continue

        var packet_sender: int = packet["remote_steam_id"]
        if packet_sender == ISteam.steam.getSteamID():
            packet_size = ISteam.steam.getAvailableP2PPacketSize(0)
            continue

        var packet_code: PackedByteArray = packet["data"]
        receive_func(packet_code)

        packet_size = ISteam.steam.getAvailableP2PPacketSize(0)
