extends Label

class_name PuzzleHint

var categories : Array[PuzzleCategory] = []

func _ready() -> void:
	add_theme_font_size_override("font_size", 8)
	
func clear_hint() -> void:
	categories.clear()
	update_hint()

func get_categories() -> Array[PuzzleCategory]:
	return categories
	
func add_category(category: PuzzleCategory) -> void:
	categories.append(category)
	update_hint()
	
func update_hint() -> void:
	text = ""
	if categories.size() == 0:
		visible = false
	else:
		visible = true
		for category in categories:
			text += category.category_name + "\n"
