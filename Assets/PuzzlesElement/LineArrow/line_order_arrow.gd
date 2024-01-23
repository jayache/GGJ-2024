extends Line2D

var direction_right := true

func _ready():
	smooth_curve()
	
func set_start_point(start: Vector2) -> void:
	points[0] = start
	smooth_curve()

func set_end_point(end: Vector2) -> void:
	points[5] = end
	smooth_curve()
	
func set_direction(right: bool) -> void:
	direction_right = right
	
func smooth_curve() -> void:
	var start := points[0]
	var end := points[5]
	points[1] = start + Vector2(20, 0)
	points[2] = points[1] + Vector2(0, 20)
	points[3] = end + Vector2(-20, -20)
	points[2].y = start.y + (end.y - start.y) / 2
	points[3].y = start.y + (end.y - start.y) / 2
	points[4] = end + Vector2(-20, 0)
