extends Node2D

const PUZZLE_BLOC_SCENE := preload("res://Assets/PuzzlesElement/PuzzleBloc/puzzle_bloc.tscn")

func _ready() -> void:
	for i in range(15):
		var bloc = PUZZLE_BLOC_SCENE.instantiate()
		get_node("Blocs").add_child(bloc)
		bloc.position = Vector2(50 + i * (bloc.size.x + 20), 100)
