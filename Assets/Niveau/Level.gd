extends Node2D

@onready var time_bar = $Node2D/time_bar
@onready var score_dialog: AcceptDialog = $ScoreDialog # Temporaire
@onready var score_label: Label = $ScoreLabel

const PUZZLE_BLOC_SCENE := preload("res://Assets/PuzzlesElement/PuzzleBloc/puzzle_bloc.tscn")
const ENEMY_SCENE := preload("res://Assets/PuzzlesElement/Enemy/enemy.tscn")
const LINE_SCENE := preload("res://Assets/PuzzlesElement/LineArrow/line_order_arrow.tscn")
const TIME_IN_SECONDS := 20

signal level_finished()
signal score_animation_finished(score: int)

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
	PuzzleCategory.new("Nourriture", 1, ["pomme", "pain", "oeuf", "lait", "blé", "four"]),
	PuzzleCategory.new("Animal", 1, ["oiseau", "chat", "poule", "vache", "chien", "mouton"]),
	PuzzleCategory.new("Ponte", 10, ["oeuf", "poule"]),
	PuzzleCategory.new("Plante", 2, ["pomme", "fleur", "arbre", "sapin"]),
	PuzzleCategory.new("Ferme", 10, ["vache", "lait", "tracteur","blé", "ordinateur", "mouton"]),
	PuzzleCategory.new("Vehicule", 10, ["tracteur", "voiture", "moto", "vélo"]),
	PuzzleCategory.new("Maison", 10, ["voiture", "chat", "chien", "ordinateur", "sapin", "four", "vélo"])
	]

func _ready() -> void:
		
	FMODRuntime.play_one_shot_path("event:/Music/GameMusic")
	
	var NUMBER_OF_BLOCS := settings.difficulty * 3
	var BLOCS_PER_LINE := NUMBER_OF_BLOCS / 3
	var screen_size := get_viewport().get_visible_rect().size
	var sprite : Sprite2D = $Node2D/Sprite2D
	hide_power_left = settings.invis_power_amount
	swap_power_left = settings.swap_power_amount
	$Node2D.position = Vector2(screen_size.x - sprite.texture.get_size().x, sprite.texture.get_size().y)
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
		if i % BLOCS_PER_LINE == BLOCS_PER_LINE - 1:
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
		$Node2D.visible = false
	put_hints()

func update_gui() -> void:
	$GUI/Pouvoirs/Ghost.text = "DISPARITION: %d" % hide_power_left
	$GUI/Pouvoirs/Swap.text = "ECHANGE: %d" % swap_power_left	

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
	update_gui()
	
func register_change(_index: int) -> void:
	put_hints()

func complete_level() -> void:
	level_in_progress = false
	for bloc in get_node("Blocs").get_children():
		bloc.set_disabled(true)
	play_score_animation()
	var score : int = await self.score_animation_finished
	score_dialog.title = "Niveau complété"
	score_dialog.dialog_text = "Score obtenu: %d" % score
	score_dialog.popup()
	await score_dialog.confirmed
	emit_signal("level_finished", score)
	
func spawn_enemy() -> void:
	var screen_size := get_viewport().get_visible_rect().size
	var enemy := ENEMY_SCENE.instantiate()
	enemy.position = [Vector2(0, 0), screen_size, Vector2(screen_size.x, 0), Vector2(0, screen_size.y)].pick_random()
	enemy.speed = 1 + settings.difficulty / 2
	enemy.speed *= 5
	add_child(enemy)
	
func put_hints() -> void:
	var last_categories : Array[PuzzleCategory] = []
	var bloc_array : Array[Node] = get_node("Blocs").get_children()
	var hint_array : Array[Node] = get_node("Hints").get_children() 
	for hint in hint_array:
		hint.clear_hint()
	return
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
	play_score_animation(true)
	score = await self.level_finished
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
	
func play_score_animation(skip_anim := false) -> void:
	var blocs := get_node("Blocs").get_children()
	var total_score := 0
	var streak := 0
	var streak_score := 0
	var wait_speed := 0.5
	for i in range(blocs.size() - 1):
		var first_bloc : PuzzleBloc = blocs[i]
		if first_bloc.swapped_with != -1:
			first_bloc = blocs[first_bloc.swapped_with]
		if first_bloc.hidden_by_power:
			continue
		var second_bloc : PuzzleBloc = blocs[i + 1]
		if second_bloc.hidden_by_power:
			var offset = 1
			while second_bloc.hidden_by_power:
				offset += 1
				second_bloc = blocs[i + offset]
		if second_bloc.swapped_with != -1:
			second_bloc = blocs[second_bloc.swapped_with]
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
			if not skip_anim:
				first_bloc.emit_success(categories_word, sc * streak)
				second_bloc.emit_success(categories_word, sc * streak)
				await get_tree().create_timer(wait_speed).timeout
		else:
			total_score += streak_score
			streak = 0
			streak_score = 0
			if not skip_anim:
				first_bloc.emit_failure()
				second_bloc.emit_failure()
				await get_tree().create_timer(wait_speed).timeout
	total_score += streak_score
	emit_signal("score_animation_finished", total_score)
	

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
	if bloc.hidden_by_power:
		register_hide_bloc(index)
	if bloc.swapped_with != -1:
		blocs[bloc.swapped_with].swapped_with = -1
		bloc.swapped_with = -1
		blocs[bloc.swapped_with].line = null
		bloc.line.queue_free()
		swap_power_left += 1
		bloc.line = null
	elif swap_power_left <= 0:
		return
	elif swap_power_selected == -1:
		swap_power_selected = index
	elif swap_power_selected != index:
		var line := Line2D.new()
		line.width = 1
		line.modulate = Color.PERU
		var second_bloc : PuzzleBloc = blocs[swap_power_selected]
		add_child(line)
		line.points = [bloc.position + bloc.size / 2, second_bloc.position + bloc.size / 2]
		bloc.line = line
		second_bloc.line = line
		second_bloc.swapped_with = index
		bloc.swapped_with = swap_power_selected
		swap_power_selected = -1
		swap_power_left -= 1
