extends Label

class_name DialogueBubble

signal dialogue_finished()
func _ready():
	text = ""

func set_dialogue(dialogue: String) -> void:
	text = ""
	for i in range(dialogue.length() + 1):
		text = dialogue.substr(0, i)
		await get_tree().create_timer(0.1).timeout
	emit_signal("dialogue_finished")
