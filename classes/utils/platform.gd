class_name Platform extends RefCounted




static func is_mobile() -> bool:
    if not OS.has_feature("web"):
        return false

    return JavaScriptBridge.eval("/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)", true)
