extends Button

func _ready():
	var button = self
	button.pressed.connect(self._button_pressed)
	button.mouse_entered.connect(self._button_hovered)

# Called when the node enters the scene tree for the first time.
func _button_pressed():
	FMODRuntime.play_one_shot_path("event:/UI/Click")
	
func _button_hovered():
	FMODRuntime.play_one_shot_path("event:/UI/hover")
