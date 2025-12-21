extends Node

signal leaderboard_request_completed
signal game_request_completed

var game_data: Dictionary = {}

var list: Dictionary = {}




func _ready() -> void :
    send_game_request()




func parse_data(category_name: String, adventurer: Adventurer, leaderboard_data: Dictionary) -> void :
    for idx in leaderboard_data["runs"].size():
        var run: Dictionary = leaderboard_data["runs"][idx]

        UserData.profile.set_floor_record(adventurer, 0)

        if not list.has(category_name):
            list[category_name] = {}

        if not list[category_name].has(adventurer):
            list[category_name][adventurer] = Leaderboard.new()

        var values: Dictionary = run["run"]["values"]

        var record: Leaderboard.Record = Leaderboard.Record.new()
        record.username = leaderboard_data["players"]["data"][idx]["names"]["international"]
        record.time = run["run"]["times"]["primary_t"]
        record.user_id = run["run"]["players"][0]["id"]

        if record.user_id == Net.speedrun_auth.id:
            pass

        list[category_name][adventurer].records.push_back(record)




func get_adventurer_name_from_id(id: String) -> String:
    for data in game_data["variables"]["data"]:
        if data["name"] == "Adventurer":
            if not data["values"]["choices"].has(id):
                continue
            return data["values"]["choices"][id]

    return ""



func get_category_name_from_id(id: String) -> String:
    for category in game_data["categories"]["data"]:
        if category["id"] == id:
            return category["name"]

    return ""



func send_game_request() -> void :
    var api_url = "https://www.speedrun.com/api/v1/games/megaloot?embed=categories,variables,leaderboard"
    HTTP.send_request(api_url, [], func(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray, args: Array):
        var json = JSON.parse_string(body.get_string_from_utf8())
        if json and "data" in json:
            game_data = json["data"]
            game_request_completed.emit()
            return

        print("Failed to parse game JSON")
    )


func send_leaderboards_request(adventurer: Adventurer) -> void :
    for category in game_data["categories"]["data"]:
        var api_url = "https://www.speedrun.com/api/v1/leaderboards/megaloot/category/"
        api_url += (category["name"] as String).to_lower().replace(" ", "-")
        api_url += "?top=100"

        var version_var_id: String = ""
        var version_id: String = ""

        var adventurer_var_id: String = ""
        var adventurer_id: String = ""

        for variable_data in game_data["variables"]["data"]:
            if variable_data["name"] == "Version":
                version_var_id = variable_data["id"]
                for choice in variable_data["values"]["choices"]:
                    if variable_data["values"]["choices"][choice] == System.get_version():
                        version_id = choice


        for data in game_data["variables"]["data"]:
            if data["name"] == "Adventurer":
                adventurer_var_id = data["id"]

                for choice in data["values"]["choices"]:
                    if (data["values"]["choices"][choice] as String).to_lower() == adventurer.name.to_lower():
                        adventurer_id = choice



        api_url += "&var-" + version_var_id + "=" + version_id
        api_url += "&var-" + adventurer_var_id + "=" + adventurer_id
        api_url += "&embed=players"


        HTTP.send_request(api_url, [], func(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray, args: Array):
            var json = JSON.parse_string(body.get_string_from_utf8())
            if json and "data" in json:
                parse_data(args[0], args[1], json["data"])
                leaderboard_request_completed.emit()
                return

            print("Failed to parse leaderboard JSON")
        , [category["name"], adventurer])
