class_name LoadingInfo extends MarginContainer


@export var progress_bar: TextureProgressBar
@export var label: GenericLabel




func clear_size() -> void :
    progress_bar.max_value = 0


func set_progress_size(arg_size: int) -> void :
    if progress_bar.max_value < arg_size:
        progress_bar.max_value = arg_size
