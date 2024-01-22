extends Node2D

const PUZZLE_BLOC_SCENE := preload("res://Assets/PuzzlesElement/PuzzleBloc/puzzle_bloc.tscn")
const TIME_IN_SECONDS := 20

@onready var time_bar: ProgressBar = $time_bar

signal level_finished()

var time_left : float = TIME_IN_SECONDS

var category_list : Array[PuzzleCategory] = [
	PuzzleCategory.new("Nourriture", 1, ["pomme", "pain", "oeuf"]),
	PuzzleCategory.new("Animal", 1, ["oiseau", "chat", "poule"]),
	PuzzleCategory.new("Ponte", 10, ["oeuf", "poule"]),
	PuzzleCategory.new("Plante", 2, ["pomme", "fleur", "arbre"])
]

func _ready() -> void:
	for i in range(15):
		var bloc = PUZZLE_BLOC_SCENE.instantiate()
		bloc.category_list = category_list
		get_node("Blocs").add_child(bloc)
		bloc.connect("bloc_changed", Callable(self, "register_change").bind(i))
		bloc.position = Vector2(50 + (i % 8) * (bloc.size.x + 50), 100 + (bloc.size.y * (i / 8)))
		var hint := Label.new()
		hint.add_theme_font_size_override("font_size", 8)
		hint.position = bloc.position
		hint.position.x += (bloc.size.x) + 5
		get_node("Hints").add_child(hint)
	time_bar.max_value = TIME_IN_SECONDS
	time_bar.value = TIME_IN_SECONDS

func _process(delta: float) -> void:
	time_left -= delta
	time_bar.value = time_left
	if time_bar.value <= 0:
		emit_signal("level_finished")

func register_change(_index: int) -> void:
	put_hints()

func put_hints() -> void:
	print("Hints")
	var last_categories : Array[PuzzleCategory] = []
	var bloc_array : Array[Node] = get_node("Blocs").get_children()
	var hint_array : Array[Node] = get_node("Hints").get_children() 
	for i in range(bloc_array.size()):
		hint_array[i].text = ""
		var bloc : PuzzleBloc = bloc_array[i]
		var new_categories := bloc.get_all_categories_for_word(bloc.get_current_word())
		for category in last_categories:
			print(category)
			print(new_categories)
			if new_categories.has(category):
				hint_array[i - 1].text += category.category_name + "\n"
				print("Found category!")
		last_categories = new_categories
		
## TODO: a faire quand les mécaniques seront plus fixées
func calc_score() -> int:
	return 0
