extends Node




func send_request(url: String, arg_headers: PackedStringArray, callable: Callable, args: Array = []) -> bool:
    var http_request: HTTPRequest = HTTPRequest.new()
    http_request.request_completed.connect( func(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
        http_request.queue_free()
        if not response_code == 200:
            print("HTTP Request failed with code: ", response_code)
            return
        callable.call(result, response_code, headers, body, args)
        )
    add_child(http_request)

    var error = http_request.request(url, arg_headers)
    print("HTTP request result: ", error)

    return error == OK
