extends Node

## Gère l'enchaînement des niveaux
## Et garde trace de la progression du joueur

var current_level := 1
var score_per_level : Array[int] = []

const LEVEL := preload("res://Assets/Niveau/Level.tscn")

func next_level() -> Node:
	var level := LEVEL.instantiate()
	var settings : LevelSettings = null
	match(current_level):
		1: settings = LevelSettings.new(1, false, 0, 0, false, false, true)
		2: settings = LevelSettings.new(2)
		3: settings = LevelSettings.new(3)
		4: settings = LevelSettings.new(4)
		5: settings = LevelSettings.new(3, false, 1, 1)
		6: settings = LevelSettings.new(4, false, 2, 2)
		7: settings = LevelSettings.new(5, false, 3, 3)
		8: settings = LevelSettings.new(5, false, 2, 2, true)
		9: settings = LevelSettings.new(6, false, 3, 3, true)
		10: settings = LevelSettings.new(5, true, 2, 2, true)
		11: settings = LevelSettings.new(6, true, 3, 3, true)
		12: settings = LevelSettings.new(7, true, 3, 3, true)
		13: settings = LevelSettings.new(7, true, 3, 3, true, true)
		14: settings = LevelSettings.new(8, true, 3, 3, true, true)
		15: settings = LevelSettings.new(9, true, 3, 3, true, true)
		
	## Paramétrer le niveau ici ?
	## Tous les 5 niveaux, une cutscene / un break se passe pour donner du feedback sur le score et permettre au joueur de souffler
	## Niveau 1: quelques blocs, indices (temps infini, niveau se termine après un certain objectif de score fixé)
	## 2-4: plus de blocs, progressivement plus de mots
	## Niveau 5: Introduction de la possibilité d'échanger et d'invisibiliser des blocs  (capacité limité et annulable)
	## Niveau 8 : Introduction des couleurs positives (points bonus, joker)
	## Niveau 10: introduction d'éléments perturbateurs qu'il faut cliquer avec la souris, sinon ils modifient les blocs aléatoirement
	## Niveau 13: Introduction des couleurs négatives (point malus, intouchable)
	
	level.settings = settings
	level.name = "Niveau%d" % current_level
	level.connect("level_finished", Callable(self, "_on_level_finished"))
	return level

func _on_level_finished(score: int) -> void:
	get_tree().root.get_node("Niveau%d" % current_level).queue_free()
	current_level += 1
	score_per_level.append(score)
	get_tree().root.add_child(next_level())
