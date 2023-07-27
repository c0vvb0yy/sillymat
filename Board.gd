extends Control
class_name Board


## value is amount of degrees the box image needs to be turned for the corressponding season to be LeftUp
const box_rotations = {
	Util.SEASONS.AUTUMN : 0,
	Util.SEASONS.SUMMER : -90,
	Util.SEASONS.SPRING : 180,
	Util.SEASONS.WINTER : 90
}

var season_positions = {
	Util.QUADRANT.LEFTUP : Util.SEASONS.AUTUMN,
	Util.QUADRANT.RIGHTUP : Util.SEASONS.SUMMER,
	Util.QUADRANT.RIGHTDOWN : Util.SEASONS.SPRING,
	Util.QUADRANT.LEFTDOWN : Util.SEASONS.WINTER,
}

var content_cards ={
	Util.QUADRANT.LEFTUP : [],
	Util.QUADRANT.RIGHTUP : [],
	Util.QUADRANT.RIGHTDOWN : [],
	Util.QUADRANT.LEFTDOWN : [],
}

@onready
var fields =[$LeftUp, $RightUp, $RightDown, $LeftDown]

var rng = RandomNumberGenerator.new()

var card_scene = preload("res://card.tscn")

@onready
var player = $"../Player"
@onready
var box = $Box
@onready
var draw_pile = $Box/DrawPile

signal kill_card
signal harvested

var active_quadrant
var active_card
var harvest ## harvest determined at point of action initiation
var stockpile_index ## index of card that we can stockpile onto

func _ready():
	
	player.connect("player_action", _on_player_action)
	player.connect("player_stockpile", _on_player_stockpile)
	rng.randomize()
	init_board()
	#debug_board()
	#print_board()

func print_board():
	for key in content_cards:
		print("Quadrant: ", Util.print_quadrant(key), " is in ", Util.print_season(season_positions[key]))
		for card in content_cards[key]:
			card.print_string()
	

func debug_board():
	#var card_arr = [[7,1],[7,1],[3,1], [6,2], [4,2]]
	for key in content_cards:
		var card_arr = [Card.new(7,1),Card.new(7,1),Card.new(3,1),Card.new(6,2),Card.new(4,2)]
		content_cards[key] = card_arr
		for cards in card_arr:
			var card = card_scene.instantiate()
			fields[key].add_child(card)
			card.get_node("Visuals").display(cards.value, cards.suit)

func init_board():
	for key in content_cards:
		resow_field(key)

func resow_field(quadrant):
	for i in range(0,3):
		var new_card = draw_pile.all_cards.pop_front()
		content_cards[quadrant].append(new_card)
		var card = card_scene.instantiate()
		fields[quadrant].add_child(card)
		card.display(new_card[0], new_card[1])


func get_season(quadrant: int):
	return season_positions[quadrant]

func change_seasons(card_suit, quadrant):
	#cant choose seasons when playing a star card yet
	if(card_suit >= 4): card_suit = rng.randi_range(0,3)
	update_season_pos_dict(card_suit, quadrant, 0)
	rotate_box()

func update_season_pos_dict(season, quadrant, breakout):
	if(season > 3):
		season = 0
	if(quadrant > 3):
		quadrant = 0
	
	season_positions[quadrant] = season
	breakout = breakout + 1
	
	if breakout == 4:
		return
	else:
		season = season + 1
		quadrant = quadrant + 1 
		update_season_pos_dict(season, quadrant, breakout)

func rotate_box():
	var leftup = season_positions[Util.QUADRANT.LEFTUP]
	var tween = get_tree().create_tween()
	tween.tween_property(box, "rotation_degrees", box_rotations[leftup], 1)

func _prepare_harvest(quadrant, card_value):
	var cards_in_quadrant = content_cards[quadrant]
	var values = []
	for card in cards_in_quadrant:
		values.append(card[0])
	var harvest_cards = find_combinations(cards_in_quadrant, card_value)
	harvest_cards = optimize_combinations(harvest_cards)
	harvest_cards = get_biggest_harvest(harvest_cards)
	return harvest_cards


func find_combinations(values, harvest_value, harvest_cards = [], current_index = 0, currCombination = null):
	for i in range(current_index, values.size()):
		var combination = ( #SumListNode.new(values[i], currCombination)
			[] if (currCombination == null)
			else currCombination.duplicate()
		) 
		combination.append(values[i])
		var combo_sum = Util.sum_of(combination)
		if(combo_sum > harvest_value):
			continue
		if(combo_sum == harvest_value):
			harvest_cards.append(combination)
		find_combinations(values, harvest_value, harvest_cards, i+1, combination)
	return harvest_cards

func optimize_combinations(harvest_cards, harvest_combinations = [], current_harvest_combination = null):
	for i in range(harvest_cards.size()):
		var combination = ( #SumListNode.new(values[i], currCombination)
			[] if (current_harvest_combination == null)
			else current_harvest_combination.duplicate()
		) 
		combination.insert(combination.size(), harvest_cards[i])
		var used_cards = []
		used_cards = Util.flatten_list(combination)
		var small_harvest_cards = harvest_cards.duplicate()
		#small_harvest_cards = Util.flatten_list(small_harvest_cards)
		small_harvest_cards.remove_at(i)
		var remaining_combinations = []
		for comb in small_harvest_cards:
			remaining_combinations.append(comb)
			for val in comb:
				if(used_cards.has(val) and remaining_combinations.has(comb)):
					remaining_combinations.erase(comb)
		if(remaining_combinations.size() == 0):
			harvest_combinations.append(combination)
			continue
		optimize_combinations(remaining_combinations, harvest_combinations, combination)
		
	return harvest_combinations

func get_biggest_harvest(arr):
	var biggest_harvest_sum = 0
	var biggest_harvest = []
	for i in range(arr.size()):
		var harvest_sum = 0
		for j in range(arr[i].size()):
			harvest_sum = harvest_sum + arr[i][j].size()
		if(harvest_sum > biggest_harvest_sum):
			biggest_harvest = arr[i]
			biggest_harvest_sum = harvest_sum
	return biggest_harvest

func _on_player_action(quadrant, card):
	active_quadrant = quadrant
	active_card = card
	var active_season = season_positions[quadrant]
	if active_season != Util.SEASONS.AUTUMN:
		player.action_node.enable_button(Util.ACTIONS.SOW)
	if active_season != Util.SEASONS.WINTER:
		harvest = []
		harvest = _prepare_harvest(active_quadrant, active_card[Util.CARD.VALUE])
		print(harvest)
		if harvest.size() >= 1:
			player.action_node.enable_button(Util.ACTIONS.HARVEST)
	if active_season != Util.SEASONS.SPRING:
		stockpile_index = find_stockpile_candidate(content_cards[quadrant], card, player.get_hand_values())
		if stockpile_index > 0:
			player.action_node.enable_button(Util.ACTIONS.STOCKPILE)
	
	
	player.action_node.ready_actions()
#	if(card.value > 10):
#		change_seasons(card.suit, quadrant)
	
	#emit_signal("kill_card")

func _on_player_sow():
	sow_card(active_quadrant, active_card)
	end_turn()

func _on_player_harvest():
	harvest_cards(harvest, active_quadrant)
	emit_signal("harvested", active_card, harvest)
	end_turn()

func _on_player_stockpile():
	stockpile_card(active_quadrant, active_card, stockpile_index)
	update_content_cards(active_quadrant, active_card, stockpile_index)
	end_turn()

func end_turn():
	check_season_change(active_card, active_quadrant)
	active_card = null
	active_quadrant = null
	harvest = null
	stockpile_index = 0
	emit_signal("kill_card")

func check_season_change(card, quadrant):
	if(card[Util.CARD.VALUE] > 10):
		change_seasons(card[Util.CARD.SUIT], quadrant)

func harvest_cards(harvest, quadrant):
	var field = fields[quadrant]
	var card_nodes = field.get_children()
	print("harvest: ", harvest)
	for combo in harvest:
		for card in combo:
			for content in content_cards[quadrant]:
				var value = content[0]
				if(card[0] == value):
					content_cards[quadrant].erase(content)
					for node in card_nodes:
						if (node.value == card[0]):
							node.queue_free()
							break
						else: if (node.stockpiled_on != null):
							var sum = node.value
							#all odd values in the stockpile array are the value of the stockpiled cards.
							for card_arr in node.stockpiled_on:
								sum += card_arr[0]
								print("stock sum: ", sum)
							if(sum == card[0]):
								node.queue_free()
								break
					break
	if (draw_pile.all_cards.size() > 3 and content_cards[quadrant] == []):
		print(draw_pile.all_cards.size())
		resow_field(quadrant)

func sow_card(quadrant, player_card):
	var value = player_card[Util.CARD.VALUE]
	var suit = player_card[Util.CARD.SUIT]
	var card = card_scene.instantiate()
	fields[quadrant].add_child(card)
	card.display(value, suit)
	content_cards[quadrant].append([value, suit])

func stockpile_card(quadrant, player_card, index):
	var stock = card_scene.instantiate()
	var root_card = fields[quadrant].get_child(index)
	root_card.add_child(stock)
	stock.display(player_card[Util.CARD.VALUE], player_card[Util.CARD.SUIT])
	root_card.stockpiled_on.append([player_card[Util.CARD.VALUE], player_card[Util.CARD.SUIT]])
	print(root_card.stockpiled_on)
	#ADD MULTIPLIER FOR NUMBER OF STOCKPILED CARDS
	print((root_card.stockpiled_on.size() / 2))
	stock.position = Vector2(1.5, 80) * (root_card.stockpiled_on.size() / 2 + 1)
	return

func update_content_cards(quadrant, card, stockpile_index):
	var quad_content = content_cards[quadrant]
	var curr_value = quad_content[stockpile_index][0]
	quad_content[stockpile_index] = [card[Util.CARD.VALUE]+curr_value, card[Util.CARD.SUIT]]
	content_cards[quadrant] = quad_content
	print(content_cards)

func find_stockpile_candidate(field_cards, player_card, player_hand):
	var index = 0
	for card in field_cards:
		for sum in player_hand:
			if(card[0] + player_card[Util.CARD.VALUE] == sum):
				print("stockpile: ", card[0], " + ",player_card[Util.CARD.VALUE], " = ", sum)
				return index
			else: if(card[0] == player_card[Util.CARD.VALUE] and card[0] == sum):
				print("stockpile: ", card[0], " + ",player_card[Util.CARD.VALUE], " = ", sum)
				return index
		index = index + 1
	return -1
