extends Control

func _on_bouton_jouer_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Cutscenes/Intro/intro.tscn")

func _process(delta):
	$Sprite2D.play()
	
func comment_jouer() -> void:
	get_tree().change_scene_to_file("res://Assets/Comment Jouer/commentjouer.tscn")
