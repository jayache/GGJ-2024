extends Node2D


func _on_timer_timeout() -> void:
	get_tree().root.get_node("Intro").queue_free()
	get_tree().root.add_child(LevelManager.next_level())
