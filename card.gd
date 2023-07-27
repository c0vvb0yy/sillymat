
class_name Card


var value := 0
var suit := Util.SUITS.AUTUMN

var stockpile_size := 0
var stockpiled_on : Card

func _init(value, suit):
	self.value = value
	self.suit = suit

func print_string():
	print(value, " of ", Util.print_suit(suit))

func get_value():
	return value
func get_suit():
	return suit
func set_value(val):
	value = val
func set_suit(col):
	suit = col
