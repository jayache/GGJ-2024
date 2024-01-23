extends Sprite2D

var speed := 5
var target := Vector2(0, 0)

func _ready() -> void:
	target = Vector2(randi_range(10, 500), randi_range(10, 500))

func _process(delta: float) -> void:
	var direction := (target - position).normalized()
	position += direction * speed * delta
	if target - position < direction * speed * delta:
		target = Vector2(randi_range(10, 500), randi_range(10, 500))


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		queue_free()
