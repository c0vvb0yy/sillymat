extends Button

signal cancel

func ready_up():
	self.pressed.connect(self._button_pressed)
	var player = get_node("/root/Game/Player")
	self.connect("cancel", player.change_active_card)

func _button_pressed():
	emit_signal("cancel")
