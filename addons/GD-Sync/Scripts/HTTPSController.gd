extends Node

























var GDSync
var connection_controller
var data_controller
var logger

var active_lb: String = ""

func _ready():
    GDSync = get_node("/root/GDSync")
    name = "HTTPSController"
    connection_controller = GDSync._connection_controller
    data_controller = GDSync._data_controller
    logger = GDSync._logger

func perform_https_request(endpoint: String, message: Dictionary) -> Dictionary:
    logger.write_log("Making HTTP request. <" + endpoint + "><" + str(message) + ">", "[HTTP]")

    var request: HTTPRequest = HTTPRequest.new()
    request.timeout = 20
    add_child(request)

    message["PublicKey"] = connection_controller._PUBLIC_KEY

    request.request(
        active_lb + "/" + endpoint, 
        [], 
        HTTPClient.METHOD_GET, 
        var_to_str(message)
    )

    var result = await request.request_completed

    logger.write_log("Completed HTTP request. <" + endpoint + "><" + str(result[1]) + ">", "[HTTP]")

    if result[1] == 200:
        var text: String = result[3].get_string_from_ascii()
        var received_message: Dictionary = str_to_var(text)
        logger.write_log("Successfull HTTP request. <" + endpoint + "><" + text + ">", "[HTTP]")
        return received_message
    else:
        logger.write_error("Failed HTTP request. <" + endpoint + "><" + str(result[1]) + ">", "[HTTP]")
        return {"Code": 1 if result[1] != 503 else 3}
