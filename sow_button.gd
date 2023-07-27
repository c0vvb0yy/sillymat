extends Button

signal sow

func ready_up():
	self.pressed.connect(self._button_pressed)
	var board = get_node("/root/Game/Board")
	self.connect("sow", board._on_player_sow)

func _button_pressed():
	emit_signal("sow")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
