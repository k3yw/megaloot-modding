class_name Math

enum Operation{ROUND_NEAREST, ROUND_DOWN, ROUND_UP}

const E: float = 2.718281828459045







static func bell(weight: float, pos: float) -> float:
    var new_pos: float = (pos + 0.1) * 10
    var length: float = 100 * new_pos
    const height: float = 0.01
    const p1: float = E * (1.0 / (height * sqrt(2 * PI)))
    var p2_top: float = pow(weight - new_pos, 2)
    var p2: float = - (p2_top / length)
    return 0.1 + pow(p1, p2)




static func calculate_diminished_stat(floor_number: int, smoothness: float, growth: float) -> float:
    if floor_number <= 0:
        return 0.0

    return ceilf((log(floor_number + smoothness) - log(smoothness)) * growth)





static func calculate_refine(base_value: float, floor_number: int) -> float:
    if is_equal_approx(base_value, 0.0):
        return 0.0

    var scaling_factor = (1 + (1.05 * floor_number) / (base_value + 1))
    var scaled_stat = base_value * scaling_factor

    return ceilf(maxf(0.0, scaled_stat))




static func big_round(num: float) -> float:
    if num >= 1e+16:
        return floorf(num / 1e+15) * 1e+15

    if num >= 10000000000000.0:
        return floorf(num / 1000000000000.0) * 1000000000000.0

    if num >= 10000000000.0:
        return floorf(num / 1000000000.0) * 1000000000.0

    if num >= 10000000.0:
        return floorf(num / 1000000.0) * 1000000.0

    if num >= 10000.0:
        return floorf(num / 1000.0) * 1000.0

    return num







static func get_percentage(max_value: float, value: float) -> float:
    if max_value <= 0.0:
        return 0.0
    return roundf((value / max_value) * 100)



static func point_to_rect_distance(p: Vector2, rect: Rect2) -> float:
    var dx = max(rect.position.x - p.x, 0, p.x - (rect.position.x + rect.size.x))
    var dy = max(rect.position.y - p.y, 0, p.y - (rect.position.y + rect.size.y))
    return sqrt(dx * dx + dy * dy)




static func get_hausdorff_distance(rect1: Rect2, rect2: Rect2) -> float:
    var points1 = [
    rect1.position, 
    rect1.position + Vector2(rect1.size.x, 0), 
    rect1.position + Vector2(0, rect1.size.y), 
    rect1.position + rect1.size
    ]

    var points2 = [
    rect2.position, 
    rect2.position + Vector2(rect2.size.x, 0), 
    rect2.position + Vector2(0, rect2.size.y), 
    rect2.position + rect2.size
    ]

    var max_dist1 = 0.0
    for p1 in points1:
        var min_dist = INF
        for p2 in points2:
            min_dist = min(min_dist, point_to_rect_distance(p1, rect2))
            max_dist1 = max(max_dist1, min_dist)

    var max_dist2 = 0.0
    for p2 in points2:
        var min_dist = INF
        for p1 in points1:
            min_dist = min(min_dist, point_to_rect_distance(p2, rect1))
            max_dist2 = max(max_dist2, min_dist)

    return max(max_dist1, max_dist2)



static func get_rect_distance(rect1: Rect2, rect2: Rect2) -> Vector2:

    var r1_min_x = rect1.position.x
    var r1_max_x = rect1.position.x + rect1.size.x
    var r1_min_y = rect1.position.y
    var r1_max_y = rect1.position.y + rect1.size.y

    var r2_min_x = rect2.position.x
    var r2_max_x = rect2.position.x + rect2.size.x
    var r2_min_y = rect2.position.y
    var r2_max_y = rect2.position.y + rect2.size.y


    var dx = 0.0
    var direction_x = 0.0
    if r1_max_x < r2_min_x:
        dx = r2_min_x - r1_max_x
        direction_x = 1.0
    elif r2_max_x < r1_min_x:
        dx = r1_min_x - r2_max_x
        direction_x = -1.0


    var dy = 0.0
    var direction_y = 0.0
    if r1_max_y < r2_min_y:
        dy = r2_min_y - r1_max_y
        direction_y = 1.0
    elif r2_max_y < r1_min_y:
        dy = r1_min_y - r2_max_y
        direction_y = -1.0


    var distance = sqrt(dx * dx + dy * dy)


    return Vector2(direction_x, direction_y).normalized() * distance



static func log_10(x) -> float:
    return log(x) * 0.4342944819032518



static func rand_success(chance: float, rng: RandomNumberGenerator = null) -> bool:
    if not rng == null:
        return rng.randf() * 100.0 < chance
    return randf() * 100.0 < chance
