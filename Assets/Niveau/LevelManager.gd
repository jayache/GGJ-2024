extends Node

## Gère l'enchaînement des niveaux
## Et garde trace de la progression du joueur

var current_level := 1
var score_per_level : Array[int] = []

const LEVEL = preload("res://Assets/Niveau/Level.tscn")

func next_level() -> Node:
	var level = LEVEL.instantiate()
	## Paramétrer le niveau ici ?
	## Tous les 5 niveaux, une cutscene / un break se passe pour donner du feedback sur le score et permettre au joueur de souffler
	## Niveau 1: quelques blocs, indices (temps infini, niveau se termine après un certain objectif de score fixé)
	## 2-4: plus de blocs, progressivement plus de mots
	## Niveau 5: Introduction de la possibilité d'échanger et d'invisibiliser des blocs  (capacité limité et annulable)
	## Niveau 8 : Introduction des couleurs positives (points bonus, joker)
	## Niveau 10: introduction d'éléments perturbateurs qu'il faut cliquer avec la souris, sinon ils modifient les blocs aléatoirement
	## Niveau 13: Introduction des couleurs négatives (point malus, intouchable)
	
	level.connect("level_finished", Callable(self, "_on_level_finished"))
	return level

func _on_level_finished(score: int) -> void:
	current_level += 1
	score_per_level.append(score)
	get_tree().root.get_node("Niveau").queue_free()
	get_tree().root.add_child(next_level())
