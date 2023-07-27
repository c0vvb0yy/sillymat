extends Button

signal harvest

# Called when the node enters the scene tree for the first time.
func ready_up():
	self.pressed.connect(self._button_pressed)
	var board = get_node("/root/Game/Board")
	self.connect("harvest", board._on_player_harvest)

func _button_pressed():
	emit_signal("harvest")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
