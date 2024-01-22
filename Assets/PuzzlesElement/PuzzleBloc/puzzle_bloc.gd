extends Node2D

const colors := [
	Color.YELLOW,
	Color.BLUE,
	Color.GREEN
]

const sprites := [
	"coeur.png",
	"bread.png",
	"bird.png"
]

enum face_order {
	CENTER,
	DOWN,
	UP,
	RIGHT,
	LEFT
}
var faces : Array[Array] = []

var currently_showing := face_order.CENTER
var hovered := false

var size := Vector2(50, 50)

func _ready() -> void:
	size = get_node("Hitbox/CollisionShape2D").shape.size
	for i in range(5):
		var current_face := [colors.pick_random(), sprites.pick_random()]
		faces.append(current_face)
		var face : ColorRect = get_node("Faces/Face%d" % (i + 1))
		face.color = current_face[0]
		face.get_node("Sprite").texture = load(current_face[1])

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
	
func _on_hitbox_mouse_entered() -> void:
	hovered = true

func _on_hitbox_mouse_exited() -> void:
	hovered = false
