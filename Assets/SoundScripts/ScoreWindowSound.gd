extends AcceptDialog

func _ready():
	var okbutton = get_ok_button()
	var scoredialog = self
	okbutton.pressed.connect(self._button_pressed)
	okbutton.mouse_entered.connect(self._button_hovered)
	scoredialog.close_requested.connect(self._button_pressed)
func _button_pressed():
	FMODRuntime.play_one_shot_path("event:/UI/Click")
	
func _button_hovered():
	FMODRuntime.play_one_shot_path("event:/UI/hover")

