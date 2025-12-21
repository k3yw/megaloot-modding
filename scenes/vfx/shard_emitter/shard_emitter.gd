@tool
class_name ShardEmitter extends Node2D

signal life_time_ended


@export_range(0, 200) var nbr_of_shards: int = 5


@export var threshold: float = 50.0


@export var min_impulse: float = 75.0


@export var max_impulse: float = 245.0


@export var lifetime: float = 5.0


@export var display_triangles: bool = false

@export var shard_scene: PackedScene

@export var sub_viewport: SubViewport



var triangles = []
var shards: Array[Shard] = []



func _ready() -> void :
    life_time_ended.connect(_on_life_time_ended)
    recalculate_shards()

    while Engine.is_editor_hint() and display_triangles:
        recalculate_shards()
        await get_tree().create_timer(1.0).timeout


func recalculate_shards() -> void :
    var _rect = sub_viewport.get_visible_rect()
    var points = []

    triangles.clear()


    points.append(_rect.position)
    points.append(_rect.position + Vector2(_rect.size.x, 0))
    points.append(_rect.position + Vector2(0, _rect.size.y))
    points.append(_rect.end)


    for i in nbr_of_shards:
        var p = _rect.position + Vector2(randi_range(0, _rect.size.x), randi_range(0, _rect.size.y))

        if p.x < _rect.position.x + threshold:
            p.x = _rect.position.x
        elif p.x > _rect.end.x - threshold:
            p.x = _rect.end.x
        if p.y < _rect.position.y + threshold:
            p.y = _rect.position.y
        elif p.y > _rect.end.y - threshold:
            p.y = _rect.end.y
        points.append(p)


    var delaunay = Geometry2D.triangulate_delaunay(points)
    for i in range(0, delaunay.size(), 3):
        triangles.append([points[delaunay[i + 2]], points[delaunay[i + 1]], points[delaunay[i]]])


    queue_redraw()






func add_shards() -> void :
    await RenderingServer.frame_post_draw
    var texture: ImageTexture = ImageTexture.create_from_image(sub_viewport.get_texture().get_image())

    for t in triangles:
        var center = Vector2((t[0].x + t[1].x + t[2].x) / 3.0, (t[0].y + t[1].y + t[2].y) / 3.0)

        var shard: Shard = shard_scene.instantiate()
        shard.position = center
        shard.hide()
        shards.append(shard)


        shard.polygon.texture = texture
        shard.polygon.polygon = t
        shard.polygon.position = - center


        var shrunk_triangles = Geometry2D.offset_polygon(t, -2)
        if shrunk_triangles.size() > 0:
            shard.collision.polygon = shrunk_triangles[0]
        else:
            shard.collision.polygon = t
        shard.collision.position = - center




func shatter() -> void :
    await add_shards()

    for s in shards:
        add_child(s)
        s.owner = get_tree().edited_scene_root

    randomize()
    get_parent().self_modulate.a = 0
    for s in shards:
        var direction = Vector2.UP.rotated(randf_range(0, 2 * PI))
        var impulse = randf_range(min_impulse, max_impulse)
        s.apply_central_impulse(direction * impulse)
        s.collision.disabled = false
        s.show()

    process_refill()



func process_refill() -> void :
    await get_tree().create_timer(lifetime).timeout
    life_time_ended.emit()

    recalculate_shards()
    add_shards()


func _on_life_time_ended() -> void :
    for s in shards:
        s.queue_free()
    shards.clear()


func _draw() -> void :
    if display_triangles:
        for i in triangles:
            draw_line(i[0], i[1], Color.WHITE, 1)
            draw_line(i[1], i[2], Color.WHITE, 1)
            draw_line(i[2], i[0], Color.WHITE, 1)
