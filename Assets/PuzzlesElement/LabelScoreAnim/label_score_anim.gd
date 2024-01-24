extends Node2D

var word := "PLANTE"
var lifetime := 2.0
var vspeed := 40

func _ready() -> void:
	$Label.text = word

func _process(delta: float) -> void:
	position.y -= vspeed * delta
	rotation_degrees = sin(lifetime * 2) * 10
	lifetime -= delta
	
	if lifetime <= 0:
		queue_free()
