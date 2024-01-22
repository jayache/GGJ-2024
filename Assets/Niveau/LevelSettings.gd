extends Node

class_name LevelSettings

var difficulty := 1 ## vitesse du jeu, ennemis et variance des mots
var no_timer := false ## Si vrai, le niveau n'a pas de timer et se termine après un objectif de score à la place
var enemies := false ## Si vrai, des ennemis apparaissent à l'écran pour perturber les blocs déjà mis
var swap_power_amount := 0 ## Si >0, il est possible d'échanger des blocs avec un pouvoir 
var invis_power_amount := 0 ## Si >0, il est possible de rendre invisible un bloc avec un pouvoir
var good_colors := false
var bad_colors := false

func _init(n_difficulty: int, n_enemies := false, n_swap_power_amount := 0, n_invis_power_amount := 0, n_good_colors := false, n_bad_colors := false, n_no_timer := false) -> void:
	difficulty = n_difficulty
	enemies = n_enemies
	swap_power_amount = n_swap_power_amount
	invis_power_amount = n_invis_power_amount
	good_colors = n_good_colors
	bad_colors = n_bad_colors
	no_timer = n_no_timer
