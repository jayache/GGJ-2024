extends Label

class_name DialogueBubble

@export var soundindex: int
var talksound: EventInstance

signal dialogue_finished()
func _ready():
	text = ""
	var event: String
	
	if soundindex == 0:
		event = "event:/SFX Game/Talking"
	if soundindex == 1:
		event = "event:/SFX Game/Talking Humoriste"
	if soundindex == 2:
		event = "event:/SFX Game/Talking Presentateur"
		
	talksound = FMODRuntime.create_instance_path(event)

func set_dialogue(dialogue: String) -> void:
	text = ""
	talksound.start()
	for i in range(dialogue.length() + 1):
		text = dialogue.substr(0, i)
		await get_tree().create_timer(0.1).timeout
	emit_signal("dialogue_finished")
	talksound.stop(FMODStudioModule.FMOD_STUDIO_STOP_ALLOWFADEOUT)
	
