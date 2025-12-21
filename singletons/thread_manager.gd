extends Node

signal thread_finished

var thread = Thread.new()

var callable_queue: Array[Callable]




func _process(_delta: float) -> void :
    if thread.is_started():
        return

    if callable_queue.size():
        var callable: Callable = callable_queue.pop_back()
        thread.start(callable)
        callable_queue.clear()



func start(callable: Callable) -> void :
    if thread.is_started():
        callable_queue.push_back(callable)
        return

    thread.start(callable)




func finish_thread() -> void :
    thread.wait_to_finish()
    thread_finished.emit()
