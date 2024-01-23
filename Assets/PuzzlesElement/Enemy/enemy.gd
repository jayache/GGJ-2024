extends Sprite2D

var speed := 5
var target := Vector2(0, 0)

func _ready() -> void:
	target = Vector2(randi_range(10, 500), randi_range(10, 500))

func _process(delta: float) -> void:
	var direction := (target - position).normalized()
	position += direction * speed
	if target - position < direction * speed:
		target = Vector2(randi_range(10, 500), randi_range(10, 500))


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		queue_free()
