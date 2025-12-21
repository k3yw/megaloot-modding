@tool
class_name AdventurerTree extends Control


@export var specialization_node_containers: Array[AdventurerTreeNode]
@export var adventurer_card_container: AdventurerTreeNode

@export var stat_nodes_a: Array[AdventurerTreeNode]
@export var stat_nodes_b: Array[AdventurerTreeNode]
@export var stat_nodes_c: Array[AdventurerTreeNode]


@export var adventurer_lines: Array[Line2D]
@export var specialization_lines: Array[Line2D]

@export var stat_a_misc_lines: Array[Line2D]
@export var stat_b_misc_lines: Array[Line2D]

@export var stat_a_line: Line2D
@export var stat_b_line: Line2D


var adventurer_selected: bool = false

var selected_specialization_idx: int = -1
var selected_stat_a_idx: int = 1
var selected_stat_b_idx: int = 2
var selected_stat_c_idx: int = -1


func _ready() -> void :
    update_all()




func _process(_delta: float) -> void :
    if not Engine.is_editor_hint():
        return

    update_all()



func update_all():
    for specialization_node_container in specialization_node_containers:
        specialization_node_container.visible = adventurer_selected

    update_stat_nodes_a()
    update_stat_nodes_b()
    update_stat_nodes_c()

    update_specialization_lines()
    update_adventurer_lines()
    update_stat_lines()



func update_adventurer_lines() -> void :
    for idx in adventurer_lines.size():
        var specialization_rect: Rect2 = specialization_node_containers[idx].get_rect()
        var adventurer_rect: Rect2 = adventurer_card_container.get_rect()

        var specialization_pos_y: int = int(specialization_rect.position.y + roundi(specialization_rect.size.y * 0.5))
        var specialization_pos_x: int = int(specialization_rect.position.x)

        var adventurer_pos_y: int = int(adventurer_rect.position.y + roundi(adventurer_rect.size.y * 0.5))
        var adventurer_pos_x: int = int(adventurer_rect.position.x + adventurer_rect.size.x) - 7

        var adventurer_line: Line2D = adventurer_lines[idx]

        adventurer_line.visible = specialization_node_containers[idx].visible
        adventurer_line.default_color = Color("#32333d")

        adventurer_line.points.resize(4)

        adventurer_line.points[0].y = adventurer_pos_y + (idx - 1) * 12
        adventurer_line.points[1].y = adventurer_pos_y + (idx - 1) * 12

        adventurer_line.points[2].y = specialization_pos_y
        adventurer_line.points[3].y = specialization_pos_y


        adventurer_line.points[0].x = adventurer_pos_x
        adventurer_line.points[1].x = adventurer_pos_x + 20

        adventurer_line.points[2].x = adventurer_pos_x + 20
        adventurer_line.points[3].x = specialization_pos_x







func update_specialization_lines() -> void :
    for idx in specialization_lines.size():
        var specialization_rect: Rect2 = specialization_node_containers[selected_specialization_idx].get_rect()
        var stat_rect: Rect2 = stat_nodes_a[idx].get_rect()

        var specialization_pos_y: int = int(specialization_rect.position.y + roundi(specialization_rect.size.y * 0.5))
        var specialization_pos_x: int = int(specialization_rect.position.x + specialization_rect.size.x)

        var stat_pos_y: int = int(stat_rect.position.y + roundi(stat_rect.size.y * 0.5))
        var stat_pos_x: int = int(stat_rect.position.x)

        var specialization_line: Line2D = specialization_lines[idx]

        specialization_line.visible = stat_nodes_a[idx].visible
        specialization_line.default_color = Color("#32333d")

        specialization_line.points.resize(4)

        specialization_line.points[0].y = specialization_pos_y + ((idx - 1) * 12)
        specialization_line.points[1].y = specialization_pos_y + ((idx - 1) * 12)

        specialization_line.points[2].y = stat_pos_y
        specialization_line.points[3].y = stat_pos_y


        specialization_line.points[0].x = specialization_pos_x
        specialization_line.points[1].x = specialization_pos_x + 20

        specialization_line.points[2].x = specialization_pos_x + 20
        specialization_line.points[3].x = stat_pos_x + 1









func update_stat_lines() -> void :

    stat_a_misc_lines[0].hide()
    stat_a_misc_lines[1].hide()

    stat_b_misc_lines[0].hide()
    stat_b_misc_lines[1].hide()

    stat_a_line.hide()
    stat_b_line.hide()


    if stat_nodes_b[selected_stat_b_idx].visible:
        stat_a_misc_lines[0].show()
        stat_a_misc_lines[1].show()
        stat_a_line.show()


    if not selected_stat_a_idx == -1:
        var stat_a_rect = stat_nodes_a[selected_stat_a_idx].get_rect()
        var stat_b_rect = stat_nodes_b[selected_stat_a_idx].get_rect()

        var stat_b_rect_0 = stat_nodes_b[0].get_rect()
        var stat_b_rect_1 = stat_nodes_b[1].get_rect()
        var stat_b_rect_2 = stat_nodes_b[2].get_rect()

        stat_a_misc_lines[0].points.resize(2)
        stat_a_misc_lines[1].points.resize(2)
        stat_a_line.points.resize(2)


        stat_a_line.points[0].y = stat_a_rect.position.y + roundi(stat_a_rect.size.y * 0.5)
        stat_a_line.points[1].y = stat_a_rect.position.y + roundi(stat_a_rect.size.y * 0.5)
        stat_a_line.points[0].x = stat_a_rect.position.x + stat_a_rect.size.x - 1
        stat_a_line.points[1].x = stat_b_rect.position.x + 1

        stat_a_misc_lines[0].points[0].x = stat_b_rect.position.x + roundi(stat_b_rect.size.x * 0.5)
        stat_a_misc_lines[0].points[1].x = stat_b_rect.position.x + roundi(stat_b_rect.size.x * 0.5)
        stat_a_misc_lines[1].points[0].x = stat_b_rect.position.x + roundi(stat_b_rect.size.x * 0.5)
        stat_a_misc_lines[1].points[1].x = stat_b_rect.position.x + roundi(stat_b_rect.size.x * 0.5)

        stat_a_misc_lines[0].points[0].y = stat_b_rect_0.position.y + stat_b_rect_0.size.y - 1
        stat_a_misc_lines[0].points[1].y = stat_b_rect_1.position.y + 1

        stat_a_misc_lines[1].points[0].y = stat_b_rect_1.position.y + stat_b_rect_1.size.y - 1
        stat_a_misc_lines[1].points[1].y = stat_b_rect_2.position.y + 1


    if stat_nodes_c[selected_stat_b_idx].visible:
        stat_b_misc_lines[0].show()
        stat_b_misc_lines[1].show()
        stat_b_line.show()


    if not selected_stat_b_idx == -1:
        var stat_b_rect = stat_nodes_b[selected_stat_b_idx].get_rect()
        var stat_c_rect = stat_nodes_c[selected_stat_b_idx].get_rect()

        var stat_c_rect_0 = stat_nodes_c[0].get_rect()
        var stat_c_rect_1 = stat_nodes_c[1].get_rect()
        var stat_c_rect_2 = stat_nodes_c[2].get_rect()

        stat_b_misc_lines[0].points.resize(2)
        stat_b_misc_lines[1].points.resize(2)
        stat_b_line.points.resize(2)

        stat_b_line.points[0].y = stat_b_rect.position.y + roundi(stat_b_rect.size.y * 0.5)
        stat_b_line.points[1].y = stat_b_rect.position.y + roundi(stat_b_rect.size.y * 0.5)
        stat_b_line.points[0].x = stat_b_rect.position.x + stat_b_rect.size.x - 1
        stat_b_line.points[1].x = stat_c_rect.position.x + 1


        stat_b_misc_lines[0].points[0].x = stat_c_rect.position.x + roundi(stat_c_rect.size.x * 0.5)
        stat_b_misc_lines[0].points[1].x = stat_c_rect.position.x + roundi(stat_c_rect.size.x * 0.5)
        stat_b_misc_lines[1].points[0].x = stat_c_rect.position.x + roundi(stat_c_rect.size.x * 0.5)
        stat_b_misc_lines[1].points[1].x = stat_c_rect.position.x + roundi(stat_c_rect.size.x * 0.5)

        stat_b_misc_lines[0].points[0].y = stat_c_rect_0.position.y + stat_c_rect_0.size.y - 1
        stat_b_misc_lines[0].points[1].y = stat_c_rect_1.position.y + 1

        stat_b_misc_lines[1].points[0].y = stat_c_rect_1.position.y + stat_c_rect_1.size.y - 1
        stat_b_misc_lines[1].points[1].y = stat_c_rect_2.position.y + 1













func update_stat_nodes_a() -> void :
    for idx in stat_nodes_a.size():
        var specialization_rect: Rect2 = specialization_node_containers[selected_specialization_idx].get_rect()
        var stat_rect: Rect2 = stat_nodes_a[idx].get_rect()
        var stat_node: AdventurerTreeNode = stat_nodes_a[idx]

        stat_node.position.x = specialization_rect.position.x + specialization_rect.size.x + 45
        stat_node.position.y = specialization_rect.position.y + roundi(specialization_rect.size.y * 0.5) - roundi(stat_rect.size.y * 0.5) + ((idx - 1) * 35)


func update_stat_nodes_b() -> void :
    for idx in stat_nodes_b.size():
        var last_stat_rect: Rect2 = stat_nodes_a[1].get_rect()
        var stat_rect: Rect2 = stat_nodes_b[idx].get_rect()
        var stat_node: AdventurerTreeNode = stat_nodes_b[idx]

        stat_node.position.x = last_stat_rect.position.x + last_stat_rect.size.x + 45
        stat_node.position.y = last_stat_rect.position.y + roundi(last_stat_rect.size.y * 0.5) - roundi(stat_rect.size.y * 0.5) + ((idx - 1) * 35)



func update_stat_nodes_c() -> void :
    for idx in stat_nodes_c.size():
        var last_stat_rect: Rect2 = stat_nodes_b[1].get_rect()
        var stat_rect: Rect2 = stat_nodes_c[idx].get_rect()
        var stat_node: AdventurerTreeNode = stat_nodes_c[idx]

        stat_node.position.x = last_stat_rect.position.x + last_stat_rect.size.x + 45
        stat_node.position.y = last_stat_rect.position.y + roundi(last_stat_rect.size.y * 0.5) - roundi(stat_rect.size.y * 0.5) + ((idx - 1) * 35)
