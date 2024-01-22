extends Node2D

const PUZZLE_BLOC_SCENE := preload("res://Assets/PuzzlesElement/PuzzleBloc/puzzle_bloc.tscn")
const TIME_IN_SECONDS := 20

@onready var time_bar: ProgressBar = $time_bar

signal level_finished()

func _ready() -> void:
	for i in range(15):
		var bloc = PUZZLE_BLOC_SCENE.instantiate()
		get_node("Blocs").add_child(bloc)
		bloc.position = Vector2(50 + i * (bloc.size.x + 20), 100)
	time_bar.max_value = TIME_IN_SECONDS
	time_bar.value = TIME_IN_SECONDS

func _process(delta: float) -> void:
	time_bar.value -= delta
	if time_bar.value <= 0:
		emit_signal("level_finished")

## TODO: a faire quand les mécaniques seront plus fixées
func calc_score() -> int:
	return 0
