extends Node2D

@onready var label_chroniqueur: Label = $Sprite2D/LabelChroniqueur
@onready var label_presentateur: Label = $Sprite2D/LabelPresentateur
@onready var label_comedien: Label = $Sprite2D/LabelComedien

var event: EventInstance

var texte := [
	"Blablabla",
	"Blablabla",
	"Blablabla",
	"Et nous accueillons notre invité de ce soir:",
	"Le comédien DJAIPA DNOM!",
	"(fadeout)",
	"Bonjour, merci de vous être déplacé jusqu'ici.",
	"Merci à vous de m'accueillir!",
	"Il paraît que les gens vous trouvent hilarant?",
	"C'est ce qu'ils disent!",
	"Faites nous rire alors.",
	"Ah."
]
func _ready():
	event = FMODRuntime.create_instance_path("event:/Music/IntroMusic")
	event.start()
	
	
func say_line(index: int, text: String) -> void:
	var label : Label
	
	if index == 0:
		label = label_chroniqueur
	if index == 1:
		label = label_presentateur
	if index == 2:
		label = label_comedien
	label.visible = true
	label.set_dialogue(text)
	await label.dialogue_finished
	await get_tree().create_timer(0.75).timeout
	label.text = ""
	label.visible = false
	

func _on_timer_timeout() -> void:
	await say_line(0, texte[0])
	await say_line(1, texte[1])
	await say_line(0, texte[2])
	await say_line(1, texte[3])
	await say_line(1, texte[4])
	var tween := create_tween()
	tween.tween_property($Overlay, "color", Color(0, 0, 0, 1), 0.7)
	await get_tree().create_timer(1.5).timeout
	$Sprite2D.texture = load("res://plateau_avec_comedien.png")
	tween = create_tween()
	tween.tween_property($Overlay, "color", Color(0, 0, 0, 0), 0.7)
	await get_tree().create_timer(0.75).timeout
	
	await say_line(1, texte[6])
	await say_line(2, texte[7])
	await say_line(0, texte[8])
	await say_line(2, texte[9])
	await say_line(0, texte[10])
	await say_line(2, texte[11])
	event.stop(FMODStudioModule.FMOD_STUDIO_STOP_ALLOWFADEOUT)
	get_tree().root.get_node("Intro").queue_free()
	get_tree().root.add_child(LevelManager.next_level())
