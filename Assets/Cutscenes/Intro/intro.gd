extends Node2D

@onready var label_chroniqueur: Label = $Sprite2D/LabelChroniqueur
@onready var label_presentateur: Label = $Sprite2D/LabelPresentateur
@onready var label_comedien: Label = $Sprite2D/LabelComedien

var texte := [
	"Blablabla",
	"Blablabla",
	"Blablabla",
	"Et nous accueillons notre invité de ce soir:",
	"Le comédien DJAIPA DNOM!",
	"(fadeout)",
	"Bonjour, merci de vous êtes déplacé jusqu'ici.",
	"Merci à vous de m'accueillir!",
	"Il paraît que les gens vous trouvent hilarant?",
	"C'est ce qu'ils disent!",
	"Faites nous rire alors.",
	"Ah."
]

func say_line(index: int, text: String) -> void:
	label_chroniqueur.text = text
	await get_tree().create_timer(1).timeout
	label_chroniqueur.text = ""
	

func _on_timer_timeout() -> void:
	await say_line(1, texte[0])
	get_tree().root.get_node("Intro").queue_free()
	get_tree().root.add_child(LevelManager.next_level())
