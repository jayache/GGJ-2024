extends Node2D


@onready var time_bar: ProgressBar = $time_bar
@onready var score_dialog: AcceptDialog = $ScoreDialog # Temporaire

const PUZZLE_BLOC_SCENE := preload("res://Assets/PuzzlesElement/PuzzleBloc/puzzle_bloc.tscn")
const TIME_IN_SECONDS := 20

signal level_finished()

var settings : LevelSettings = LevelSettings.new(1)

var level_in_progress := true
var time_left : float = TIME_IN_SECONDS

## TODO: ajouter des mots/catégories
## Aussi: Ajouter d'autres types de liaisons ?
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
		var hint := PuzzleHint.new()
		hint.position = bloc.position
		hint.position.x += (bloc.size.x) + 5
		get_node("Hints").add_child(hint)
	time_bar.max_value = TIME_IN_SECONDS
	time_bar.value = TIME_IN_SECONDS
	put_hints()

func _process(delta: float) -> void:
	if not level_in_progress:
		return
	time_left -= delta
	time_bar.value = time_left
	if time_bar.value <= 0:
		var score := calc_score()
		level_in_progress = false
		score_dialog.title = "Niveau complété"
		score_dialog.dialog_text = "Score obtenu: %d" % score
		score_dialog.popup()
		await score_dialog.confirmed
		emit_signal("level_finished", score)

func register_change(_index: int) -> void:
	put_hints()

func put_hints() -> void:
	var last_categories : Array[PuzzleCategory] = []
	var bloc_array : Array[Node] = get_node("Blocs").get_children()
	var hint_array : Array[Node] = get_node("Hints").get_children() 
	for hint in hint_array:
		hint.clear_hint()
	for i in range(bloc_array.size()):
		var bloc : PuzzleBloc = bloc_array[i]
		var new_categories := bloc.get_all_categories_for_word(bloc.get_current_word())
		for category in last_categories:
			if new_categories.has(category):
				var previous_hint : PuzzleHint = hint_array[i - 1]
				previous_hint.add_category(category)
		last_categories = new_categories
		
## TODO: a faire quand les mécaniques seront plus fixées
func calc_score() -> int:
	var score := 0
	var current_streak := 0
	var current_streak_score := 0
	var last_hint : Array[PuzzleCategory] = []
	var current_streak_color := 0
	var current_streak_score_color := 0
	
	var last_color := Color.CORAL
	var bloc_array : Array[Node] = get_node("Blocs").get_children()

	for i in range(bloc_array.size()):
		var bloc : PuzzleBloc = bloc_array[i]
		var new_color := bloc.get_current_color()
		if new_color == last_color:
				current_streak_color += 100
				current_streak_score_color += 1
				
				## TODO FAIRE LES POINTS SUR LA SUITE DE COULEUR (Ca marche)
		last_color = new_color
	print(current_streak_score_color)
	
	for node_hint in get_node("Hints").get_children():
		var hint : PuzzleHint = node_hint
		var new_hint = hint.get_categories()
		if new_hint == [] and last_hint != []:
			score += current_streak_score
			current_streak_score = 0
			current_streak = 0
		elif new_hint != []:
			current_streak += 1
			for cat in new_hint:
				current_streak_score += cat.category_base_value * current_streak
	
	score += current_streak_score
	return score
