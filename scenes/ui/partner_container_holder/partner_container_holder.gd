class_name PartnerContainerHolder extends HBoxContainer


signal hovered_partner_idx_changed

var hovered_partner_idx: int = -1
var partners: Array[Player] = []



func _ready() -> void :
    update_partner_containers()



func _process(_delta: float) -> void :
    var initial_hovered_partner_idx: int = hovered_partner_idx
    hovered_partner_idx = -1

    for idx in partners.size():
        var parter_container: PartnerContainer = get_child(idx)
        if UI.is_hovered(parter_container):
            hovered_partner_idx = idx

    if not initial_hovered_partner_idx == hovered_partner_idx:
        hovered_partner_idx_changed.emit()



func update_partner_containers() -> void :
    for child in get_children():
        child.queue_free()

    if Lobby.data.players.size() <= 1:
        return

    for player in Lobby.data.players:
        if player.client_id == Lobby.get_client_id():
            continue
        var parter_container: PartnerContainer = preload("res://scenes/ui/partner_container/partner_container.tscn").instantiate()
        add_child(parter_container)
        parter_container.adventurer_portrait.set_adventurer(player.adventurer)
