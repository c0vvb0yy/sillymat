extends Control

@export
var radius := 175

var layout_pos := []
var active_buttons := []

@onready
var harvest_button = preload("res://harvest_button.tscn")
@onready
var sow_button = preload("res://sow_button.tscn")
@onready
var stockpile_button = preload("res://stockpile_button.tscn")
@onready
var cancel_button = preload("res://cancel.tscn")

func ready_actions():
	if(active_buttons.size() == 0):
		print("no valid actions")
		return
	calc_button_positions(active_buttons.size())
	
	for n in active_buttons.size():
		print(n)
		print(layout_pos[n])
		buttons(n)
	
	add_cancel_button()

func add_cancel_button():
	var cancel = cancel_button.instantiate()
	add_child(cancel)
	#cancel.position += Vector2(72, 72)

func buttons(index):
	var button = active_buttons[index].instantiate()
	add_child(button)
	var tween := get_tree().create_tween()
	tween.tween_property(button, "position", layout_pos[index], 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(button.ready_up)

func calc_button_positions(actions:int):
	layout_pos.clear()
	var angle_offset := 0
	var x_offset = 0#145
	var y_offset = 0#145
	for p in range(actions+1):
		layout_pos.append(Vector2((sin(2*PI/actions*p+angle_offset)*radius) - x_offset, (cos(2*PI/actions*p+angle_offset)*radius)- y_offset))

func enable_button(button:=9):
	match button:
		Util.ACTIONS.SOW:
			active_buttons.append(sow_button)
		Util.ACTIONS.HARVEST:
			active_buttons.append(harvest_button)
		Util.ACTIONS.STOCKPILE:
			active_buttons.append(stockpile_button)
		9:
			active_buttons.append(sow_button)
			active_buttons.append(harvest_button)
			active_buttons.append(stockpile_button)

func disable_button(button:=9):
	match button:
		Util.ACTIONS.SOW:
			active_buttons.erase(sow_button)
		Util.ACTIONS.HARVEST:
			active_buttons.erase(harvest_button)
		Util.ACTIONS.STOCKPILE:
			active_buttons.erase(stockpile_button)
		9:
			active_buttons.clear()

func clear():
	disable_button()
	for n in get_children():
		n.queue_free()
