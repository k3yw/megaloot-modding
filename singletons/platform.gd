extends Node



var steam = null




func _init() -> void :
    if Engine.has_singleton("Steam"):
        steam = Engine.get_singleton("Steam")
        steam.steamInit()


func is_mobile() -> bool:
    if not OS.has_feature("web"):
        return false

    return JavaScriptBridge.eval("/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)", true)

func set_rich_presence(key: String, value: String) -> void :
    if not is_active():
        return
    steam.setRichPresence(key, value)


func update_rich_presence_floor(floor_number: int) -> void :
    if not is_active():
        return
    set_rich_presence("SCORE", "Floor " + str(floor_number + 1))


func get_steam_name(steam_id: int) -> String:
    if not is_active():
        return ""

    steam.getFriendPersonaName(steam_id)
    await steam.persona_state_change
    var player_name: String = steam.getFriendPersonaName(steam_id)
    return player_name


func get_achievement(achievement_name: String) -> void :
    if not is_active():
        return
    steam.setAchievement(achievement_name)
    steam.storeStats()


func has_achievement(achievement_name: String) -> bool:
    if not is_active():
        return false
    return steam.getAchievement(achievement_name)["achieved"]


func get_own_name() -> String:
    if not is_active():
        return ""

    return steam.getPersonaName()


func get_language() -> String:
    if not is_active():
        return ""
    return steam.getCurrentGameLanguage()


func get_steam_id() -> int:
    if not is_active():
        return -1

    return steam.getSteamID()


func get_app_id() -> int:
    if not is_active():
        return -1

    return steam.getAppID()


func is_active() -> bool:
    return is_instance_valid(steam)
