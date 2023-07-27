extends TextureRect

#Karten werden nur als ihre values nicht in der Klasse abgespeichert.
#Wir nehmen der reihe nach die daten aus dem Stapel und instanzieren die Klassen dann damit

#[[1-13],[0-4]]
var all_cards =[]

# Called when the node enters the scene tree for the first time.
func _ready():
	for suit in range(0,5):
		for value in range(1,14):
			all_cards.append([value,suit])
	all_cards.shuffle()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func no_more_cards():
	self.self_modulate = Color(1,1,1,0)
