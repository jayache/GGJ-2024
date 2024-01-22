extends Node

class_name PuzzleCategory

## Nom affiché de la catégorie
var category_name := ""
## Score de base de la catégorie
var category_base_value := 1
## Liste de mots
var word_list : Array[String] = []

func _init(n_category_name: String, n_category_base_value: int, n_word_list: Array[String]) -> void:
	category_name = n_category_name
	category_base_value = n_category_base_value
	word_list = n_word_list

## Retourne true si le mot est dans la catégorie
func is_in_category(word: String) -> bool:
	return word_list.has(word)

func get_words() -> Array[String]:
	return word_list
