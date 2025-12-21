class_name AdventurerProfilePopup extends PopupContainer


@export var overview_container: AdventurerOverviewContainer
@export var records_container: RecordsContainer
@export var submit_run_button: TabButton
@export var tab_container: GenericTabContainer


var current_adventurer: Adventurer




func _process(delta: float) -> void :
    super._process(delta)

    if Input.is_action_just_pressed("press"):
        if UI.is_hovered(submit_run_button):
            OS.shell_open("https://www.speedrun.com/Megaloot/runs/new?h=floor-60&x=wkpxme02")



func update_all(adventurer: Adventurer) -> void :
    overview_container.update_adventurer(adventurer)

    if not current_adventurer == adventurer:
        current_adventurer = adventurer
        records_container.clear()
        update_leaderboard(adventurer)




func update_leaderboard(adventurer: Adventurer) -> void :
    if not Leaderboards.list.has(adventurer):
        var loaded: bool = false
        Leaderboards.send_leaderboards_request(adventurer)

        records_container.loading_animation.show()

        while not loaded:
            await get_tree().process_frame
            for category in Leaderboards.list:
                if Leaderboards.list[category].has(adventurer):
                    loaded = true


    records_container.update(adventurer)
