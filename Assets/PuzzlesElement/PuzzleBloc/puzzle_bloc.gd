extends Node2D

class_name PuzzleBloc

signal bloc_changed()

const  colors := [
	Color.RED,
	Color.BLUE,
	Color.GREEN,
	Color.AQUA,
	Color.CHOCOLATE,
	Color.CYAN,
	Color.DEEP_PINK
]

const sprites := [
	"coeur.png",
	"bread.png",
	"bird.png"
]

var category_list : Array[PuzzleCategory] = []

enum face_order {
	CENTER,
	DOWN,
	UP,
	RIGHT,
	LEFT
}
var faces : Array[Array] = []

var currently_showing := face_order.CENTER:
	set = change_currently_showing
var hovered := false

var size := Vector2(50, 50)

func _ready() -> void:
	var all_words : Array[String] = []
	for category in category_list:
		all_words += category.get_words() ## Les mots en plusieurs examplaires ont plus de chances d'apparaître
	all_words += all_words ## On augmente (artificiellement) la quantité de mots disponibles
	size = get_node("Hitbox/CollisionShape2D").shape.size
	
	for i in range(5):
		var rnd := randi_range(0, all_words.size() - 1)
		var current_face := [all_words[rnd]]

		
		var rng = randi_range(0, colors.size() - 1)
		var colora = colors[rng]
		current_face.append(colora)		
		print(current_face)
		
		all_words.remove_at(rnd)
		faces.append(current_face)
		print(faces)
		
		var face : ColorRect = get_node("Faces/Face%d" % (i + 1))
		var f = get_node("Faces/Face%d" % (i + 1))
		f.modulate = colora
		#face.get_node("Sprite").texture = load(current_face[1])
		face.get_node("Label").text = current_face[0]

func change_currently_showing(new_orientation: face_order):
	currently_showing = new_orientation
	emit_signal("bloc_changed")
	
func _process(_delta: float) -> void:
	if hovered:
		if currently_showing == face_order.CENTER:
			if Input.is_action_just_pressed("ui_down"):
				currently_showing = face_order.DOWN
			elif Input.is_action_just_pressed("ui_up"):
				currently_showing = face_order.UP
			elif Input.is_action_just_pressed("ui_right"):
				currently_showing = face_order.RIGHT
			elif Input.is_action_just_pressed("ui_left"):
				currently_showing = face_order.LEFT
		else:
			if currently_showing == face_order.DOWN and Input.is_action_just_pressed("ui_up"):
				currently_showing = face_order.CENTER
			if currently_showing == face_order.UP and Input.is_action_just_pressed("ui_down"):
				currently_showing = face_order.CENTER
			if currently_showing == face_order.LEFT and Input.is_action_just_pressed("ui_right"):
				currently_showing = face_order.CENTER
			if currently_showing == face_order.RIGHT and Input.is_action_just_pressed("ui_left"):
				currently_showing = face_order.CENTER
	for child in get_node("Faces").get_children():
		child.visible = false
	get_node("Faces/Face%d" % (currently_showing + 1)).visible = true

func get_all_categories_for_word(word: String) -> Array[PuzzleCategory]:
	var ret : Array[PuzzleCategory] = []
	for category in category_list:
		if category.is_in_category(word):
			ret.append(category)
	return ret
		
func change_face(face: face_order, content: String) -> void:
	get_node("Faces/Face%d/Sprite" % face).texture = load(content)

func get_current_word() -> String:
	return faces[currently_showing][0]
	
func get_current_color() -> Color:
	return faces[currently_showing][1]
	
func _on_hitbox_mouse_entered() -> void:
	hovered = true

func _on_hitbox_mouse_exited() -> void:
	hovered = false
