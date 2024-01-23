extends ReferenceRect

signal emptied

var cards_drawn
@export var card_loader: Resource

# Called when the node enters the scene tree for the first time.
func _ready():
	cards_drawn = 0
	setup_initial_deck()

func setup_initial_deck():
	var cards = card_loader.get_cards(9)
	for card in cards:
		card.visible = false
		add_child(card)
	print(get_children())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _prcess(delta):
	pass

# On button press, 'pop' the top card data, and instantiate a new card
# Emit the new card to be listened to by main
func draw():
	var drawn_card = get_children()[1]
	remove_child(drawn_card)
	
	drawn_card.visible = true
	drawn_card.mouse_filter = MOUSE_FILTER_STOP
	drawn_card.get_node("TextureButton").mouse_filter = MOUSE_FILTER_STOP
	return drawn_card
	
