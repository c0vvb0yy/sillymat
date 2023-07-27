class_name Util

enum ACTIONS {SOW, HARVEST, STOCKPILE}
enum SEASONS {AUTUMN, SUMMER, SPRING, WINTER}
enum QUADRANT {LEFTUP, RIGHTUP, RIGHTDOWN, LEFTDOWN}
enum SUITS {AUTUMN, SUMMER, SPRING, WINTER, STAR}
enum CARD {VALUE, SUIT}

static func sum_of(array):
	var sum = 0
	for card in array:
		sum = sum + card[0] 
	return sum

static func flatten_list(list):
	var result = []
	for element in list:
		for value in element:
			result.append(value)
	return result

static func print_quadrant(index):
	var quadrant_string = ""
	match index:
		0:
			quadrant_string = "Left up"
		1:
			quadrant_string = "Right up"
		2:
			quadrant_string = "Right down"
		3:
			quadrant_string = "Left down"
	return quadrant_string

static func print_season(index):
	var season_string = ""
	match index:
		0:
			season_string = "Autumn"
		1:
			season_string = "Summer"
		2:
			season_string = "Spring"
		3:
			season_string = "Winter"
	return season_string

static func print_suit(index):
	var suit_str = ""
	match index:
		0:
			suit_str = "Autumn"
		1:
			suit_str = "Summer"
		2:
			suit_str = "Spring"
		3:
			suit_str = "Winter"
		4:
			suit_str = "Stars"
	return suit_str
