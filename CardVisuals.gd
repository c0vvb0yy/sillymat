extends Control

enum SUITS {AUTUMN, SUMMER, SPRING, WINTER, STAR}
@export
var suit_image : Array[Texture]

@onready
var suit_texture = $Visuals/Suit
@onready
var val_label1 = $Visuals/Value1
@onready
var val_label2 = $Visuals/Value2

var suit
var value

var stockpiled_on = []

func display(value, suit):
	self.value = value
	self.suit = suit
	suit_texture.texture = suit_image[suit]
	val_label1.text = str(value)
	val_label2.text = str(value)
