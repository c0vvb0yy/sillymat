extends Control

@onready
var board = $"../Board"
@onready
var draw_pile = $"../Board/Box/DrawPile"
@onready
var hand_node = $Hand
@onready
var card_node = $ActiveCard
@onready
var action_node = $Actions
@onready
var middle = get_viewport_rect().size
@onready
var active_quadrant = Util.QUADRANT.LEFTUP
@onready
var active_season = board.get_season(0)

var card_scene = preload("res://card.tscn")
var card
var card_data
var hand = []
var harvest_pile = []

var rng = RandomNumberGenerator.new()

var is_acting := false

#signal player_sow
#signal player_harvest
signal player_stockpile
signal player_action

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	create_hand()
	#debug_hand()
	board.connect("kill_card", discard_card)
	board.connect("harvested", update_harvest_pile)

func update_harvest_pile(card, harvest):
	harvest_pile.append(card)
	for combo in harvest:
		for board_card in combo:
			harvest_pile.append(board_card)
	print(harvest_pile)

func discard_card():
	is_acting = false
	action_node.clear()
	card.queue_free()
	card = null
	create_card()

func debug_hand():
	for i in range(0,4):
		var card_data = [10,1]
		var drawn_card = card_scene.instantiate()
		drawn_card.value = card_data[0]
		drawn_card.suit = card_data[1]
		hand_node.add_child(drawn_card)
		hand.append(card_data)

func create_hand():
	for i in range(0,4):
		var card_data = draw_pile.all_cards.pop_front()
		var card = card_scene.instantiate()
		hand_node.add_child(card)
		card.display(card_data[0], card_data[1])
		hand.append(card_data)

func create_card():
	var card_data = draw_pile.all_cards.pop_front()
	if(card_data == null):
		print("NO MORE CARDS")
		draw_pile.no_more_cards()
		return
	var drawn_card = card_scene.instantiate()
	hand_node.add_child(drawn_card)
	drawn_card.display(card_data[0], card_data[1])
	hand.append(card_data)

func get_hand_values():
	var values = []
	for card in hand:
		values.append(card[0])
	return values

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(card != null && !is_acting):
		card.position = get_viewport().get_mouse_position() * 2
		card.rotation = middle.angle_to_point(card.position) + 80
		determine_quadrant()
	pass

func _input(event):
	if(event is InputEventKey and card == null):
		match event.keycode:
			KEY_1:
				set_active_card(0)
			KEY_2:
				set_active_card(1)
			KEY_3:
				set_active_card(2)
			KEY_4:
				set_active_card(3)
	if(card != null):
		if event is InputEventMouseButton and event.pressed == true and !is_acting:
			is_acting = true
			match event.button_index:
				1:
					#emit_signal("player_sow", active_quadrant, card_data)
					emit_signal("player_action", active_quadrant, card_data)
					action_node.position = get_viewport().get_mouse_position() * 2 - Vector2(145, 145)
				#2:
					#emit_signal("player_harvest", active_quadrant, card_data)
				3:
					emit_signal("player_stockpile", active_quadrant, card_data)
				
		else: if event is InputEventKey and event.keycode == KEY_SPACE:
			change_active_card()


func set_active_card(card_index):
	#Get child from hbox
	var activated_card = hand_node.get_child(card_index)
	hand_node.remove_child(activated_card)
	#make it child of the activated card node. It needs to be in that node and not just added as a child to the player, bc then the card overrides the actions
	#mouse filtering does not do anything
	card_node.add_child(activated_card)
	card = activated_card
	card_data = hand[card_index]
	hand.remove_at(card_index)

func change_active_card():
	card_node.remove_child(card)
	hand_node.add_child(card)
	hand.append(card_data)
	card_data = null
	card = null
	action_node.clear()
	is_acting = false

func determine_quadrant():
	if(card.position.x < middle.x && card.position.y < middle.y && active_quadrant != Util.QUADRANT.LEFTUP):
		active_quadrant = Util.QUADRANT.LEFTUP
	if(card.position.x > middle.x && card.position.y < middle.y && active_quadrant != Util.QUADRANT.RIGHTUP):
		active_quadrant = Util.QUADRANT.RIGHTUP
	if(card.position.x > middle.x && card.position.y > middle.y && active_quadrant != Util.QUADRANT.RIGHTDOWN):
		active_quadrant = Util.QUADRANT.RIGHTDOWN
	if(card.position.x < middle.x && card.position.y > middle.y && active_quadrant != Util.QUADRANT.LEFTDOWN):
		active_quadrant = Util.QUADRANT.LEFTDOWN
