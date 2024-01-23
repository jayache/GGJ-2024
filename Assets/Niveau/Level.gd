extends Node2D

@onready var time_bar = $Node2D/time_bar
@onready var score_dialog: AcceptDialog = $ScoreDialog # Temporaire
@onready var score_label: Label = $ScoreLabel

const PUZZLE_BLOC_SCENE := preload("res://Assets/PuzzlesElement/PuzzleBloc/puzzle_bloc.tscn")
const ENEMY_SCENE := preload("res://Assets/PuzzlesElement/Enemy/enemy.tscn")
const LINE_SCENE := preload("res://Assets/PuzzlesElement/LineArrow/line_order_arrow.tscn")
const TIME_IN_SECONDS := 3

signal level_finished()
signal score_animation_finished()

var settings := LevelSettings.new(9, true, 5, 5, true, true)
var enemy_cooldown := 0.0
var swap_power_left := 0
var hide_power_left := 0
var swap_power_selected := -1

var level_in_progress := true
var time_left : float = TIME_IN_SECONDS

## TODO: ajouter des mots/catégories
## Aussi: Ajouter d'autres types de liaisons ?

var category_list : Array[PuzzleCategory] = [	
	PuzzleCategory.new("Nourriture", 1, ["pomme", "pain", "oeuf", "lait"]),
	PuzzleCategory.new("Animal", 1, ["oiseau", "chat", "poule", "vache"]),
	PuzzleCategory.new("Ponte", 10, ["oeuf", "poule"]),
	PuzzleCategory.new("Plante", 2, ["pomme", "fleur", "arbre"]),
	PuzzleCategory.new("Ferme", 2, ["vache", "lait"])
	]

func _ready() -> void:
	var NUMBER_OF_BLOCS := settings.difficulty * 3
	var BLOCS_PER_LINE := NUMBER_OF_BLOCS / 3
	var screen_size := get_viewport().get_visible_rect().size
	var middle := screen_size / 2
	var last_line = null
	for i in range(NUMBER_OF_BLOCS): ## La difficulté max du jeu est 9, donc 27 blocs max
		var bloc : PuzzleBloc = PUZZLE_BLOC_SCENE.instantiate()
		bloc.generate_bad_color = settings.bad_colors
		bloc.generate_good_color = settings.good_colors
		var BLOC_PADDING := Vector2(max(bloc.size.x * 0.8, 70), max(bloc.size.y * 0.8, 70))
		bloc.category_list = category_list
		get_node("Blocs").add_child(bloc)
		bloc.connect("bloc_changed", Callable(self, "register_change").bind(i))
		bloc.connect("bloc_hidden_selected", Callable(self, "register_hide_bloc").bind(i))
		bloc.connect("bloc_swap_selected", Callable(self, "register_swap_bloc").bind(i))
		## Les blocs sont toujours organisés en 3 rangées
		var start_x := middle.x - ((NUMBER_OF_BLOCS / 3) * (bloc.size.x + BLOC_PADDING.x) * 0.5)
		var start_y := middle.y - (bloc.size.y + BLOC_PADDING.y) * 1.5
		var position_x := start_x + (i % BLOCS_PER_LINE) * (bloc.size.x + BLOC_PADDING.x)
		var position_y := start_y + ((bloc.size.y + BLOC_PADDING.y) * (i / BLOCS_PER_LINE))
		bloc.position = Vector2(position_x, position_y)
		if last_line != null:
			last_line.set_end_point(bloc.position - Vector2(bloc.size.x, 0))
			add_child(last_line)
			last_line = null
		if i % BLOCS_PER_LINE == BLOCS_PER_LINE - 1 and i != 0:
			var line := LINE_SCENE.instantiate()
			line.set_start_point(bloc.position + Vector2(bloc.size.x, 0))
			last_line = line
		var hint := PuzzleHint.new()
		hint.position = bloc.position
		hint.position.x += (bloc.size.x) + 5
		get_node("Hints").add_child(hint)
	time_bar.max_value = TIME_IN_SECONDS
	time_bar.value = TIME_IN_SECONDS
	if settings.no_timer:
		time_bar.visible = false
	put_hints()

func _process(delta: float) -> void:
	if not level_in_progress:
		return
	if settings.enemies:
		if enemy_cooldown <= 0:
			spawn_enemy()
			enemy_cooldown = 10 / settings.difficulty
		else:
			enemy_cooldown -= delta
	if not settings.no_timer:
		time_left -= delta
		time_bar.value = time_left
		$Node2D/time_bar/Label.text = "%d" % time_left
		
		if time_bar.value <= 0:
			complete_level()
	if settings.no_timer and calc_score() > 10:
		complete_level()
	
func register_change(_index: int) -> void:
	put_hints()
	var score := calc_score()
	score_label.text = "Score: %d" % score

func complete_level() -> void:
	level_in_progress = false
	play_score_animation()
	await self.score_animation_finished
	var score := calc_score()
	score_dialog.title = "Niveau complété"
	score_dialog.dialog_text = "Score obtenu: %d" % score
	score_dialog.popup()
	await score_dialog.confirmed
	emit_signal("level_finished", score)
	
func spawn_enemy() -> void:
	var enemy := ENEMY_SCENE.instantiate()
	enemy.speed = 1 + settings.difficulty / 2
	enemy.speed *= 5
	add_child(enemy)
	
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
	var bloc_array : Array[Node] = get_node("Blocs").get_children()
	
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
	
func get_all_categories_for_word(word: String) -> Array[PuzzleCategory]:
	var ret : Array[PuzzleCategory] = []
	for category in category_list:
		if category.is_in_category(word):
			ret.append(category)
	return ret
	
func word_share_category(a: String, b: String) -> bool:
	var new_categories := get_all_categories_for_word(a)
	for category in get_all_categories_for_word(b):
		if new_categories.has(category):
			return true
	return false

func word_share_category_score(a: String, b: String) -> int:
	var score := 0
	var new_categories := get_all_categories_for_word(a)
	for category in get_all_categories_for_word(b):
		if new_categories.has(category):
			score += category.category_base_value
	return score
	

func word_share_category_words(a: String, b: String) -> Array[PuzzleCategory]:
	var ret : Array[PuzzleCategory] = []
	var new_categories := get_all_categories_for_word(a)
	for category in get_all_categories_for_word(b):
		if new_categories.has(category):
			ret.append(category)
	return ret
	
func play_score_animation() -> void:
	var blocs := get_node("Blocs").get_children()
	var previous_categories : Array[PuzzleCategory]= []
	var total_score := 0
	var streak := 0
	var streak_score := 0
	var wait_speed := 0.5
	for i in range(blocs.size() - 1):
		var first_bloc : PuzzleBloc = blocs[i]
		if first_bloc.hidden_by_power:
			continue
		var second_bloc : PuzzleBloc = blocs[i + 1]
		if second_bloc.hidden_by_power:
			var offset = 1
			while second_bloc.hidden_by_power:
				offset += 1
				second_bloc = blocs[i + offset]
		var a := first_bloc.get_current_word()
		var b := second_bloc.get_current_word()
		var a_color = first_bloc.get_current_color()
		var b_color = second_bloc.get_current_color()
		if word_share_category(a, b) or [a_color, b_color].has(Color.GREEN):
			var cats := word_share_category_words(a, b)
			var categories_word := ""
			for cat in cats:
				categories_word += cat.category_name + "\n"
			var sc := word_share_category_score(a, b)
			if a_color == Color.BLUE:
				sc *= 2
			if b_color == Color.BLUE:
				sc *= 2
			if a_color == Color.RED:
				sc *= 0
			if b_color == Color.RED:
				sc *= 0
			if b_color == Color.PURPLE:
				sc -= 2
			if a_color == Color.PURPLE:
				sc -= 2		
			streak += 1
			streak_score += sc * streak
			first_bloc.emit_success(categories_word, sc * streak)
			second_bloc.emit_success(categories_word, sc * streak)
			await get_tree().create_timer(wait_speed).timeout
		else:
			total_score += streak_score
			streak = 0
			streak_score = 0
			first_bloc.emit_failure()
			second_bloc.emit_failure()
			await get_tree().create_timer(wait_speed).timeout
	emit_signal("score_animation_finished")

func register_hide_bloc(index: int) -> void:
	var blocs := get_node("Blocs").get_children()
	var bloc : PuzzleBloc = blocs[index]
	if bloc.hidden_by_power:
		bloc.hidden_by_power = false
		hide_power_left += 1
	elif not bloc.hidden_by_power:
		if hide_power_left > 0:
			bloc.hidden_by_power = true
			hide_power_left -= 1

func register_swap_bloc(index: int) -> void:
	var blocs := get_node("Blocs").get_children()
	var bloc : PuzzleBloc = blocs[index]
	if bloc.swapped_with != -1:
		blocs[bloc.swapped_with].swapped_with = -1
		bloc.swapped_with = -1
	elif swap_power_selected == -1:
		swap_power_selected = index
	elif swap_power_selected != index:
		var second_bloc : PuzzleBloc = blocs[swap_power_selected]
		second_bloc.swapped_with = index
		bloc.swapped_with = swap_power_selected
		swap_power_selected = -1
