class_name Await








static func emit(sig: Signal, args: Array = []) -> void :
    for conn in sig.get_connections():
        var callable: Callable = conn["callable"]
        await callable.callv(args)
