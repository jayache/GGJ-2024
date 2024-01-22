extends Node

## Gère l'enchaînement des niveaux
## Et garde trace de la progression du joueur

var current_level := 1
var score_per_level : Array[int] = []

const LEVEL = preload("res://Assets/Niveau/Level.tscn")

func next_level() -> Node:
	var level = LEVEL.instantiate()
	## Paramétrer le niveau ici ?
	level.connect("level_finished", Callable(self, "_on_level_finished"))
	
	return level

func _on_level_finished(score: int) -> void:
	get_tree().root.get_node("Niveau").queue_free()
	get_tree().root.add_child(next_level())
