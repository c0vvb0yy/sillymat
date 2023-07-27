extends Button

signal stockpile

func ready_up():
	self.pressed.connect(self._button_pressed)
	var board = get_node("/root/Game/Board")
	self.connect("stockpile", board._on_player_stockpile)

func _button_pressed():
	emit_signal("stockpile")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
