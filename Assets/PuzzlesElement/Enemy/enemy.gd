extends Sprite2D

var speed := 5
var speed_boost := 2
var target := Vector2(0, 0)

func _ready() -> void:
	choose_new_target()

func choose_new_target() -> void:
	var screen_size := get_viewport().get_visible_rect().size
	target = Vector2(randi_range(0, screen_size.x), randi_range(0, screen_size.y))

func _process(delta: float) -> void:
	var direction := (target - position).normalized()
	position += direction * speed * delta * speed_boost
	if speed_boost > 1:
		speed_boost -= delta
	if speed_boost < 1:
		speed_boost = 1
	if target - position < direction * speed * delta:
		choose_new_target()

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		queue_free()
