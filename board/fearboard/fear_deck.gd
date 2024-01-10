extends ReferenceRect

signal emptied

var cards_drawn

# Called when the node enters the scene tree for the first time.
func _ready():
	cards_drawn = 0
	setup_initial_deck()

func setup_initial_deck():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _prcess(delta):
	pass

# On button press, 'pop' the top card data, and instantiate a new card
# Emit the new card to be listened to by main
func draw():
	# Get a random card from the current stage
	var random_card_index = randi() % (get_child_count()-1)
	var drawn_card = get_children()[random_card_index]
	remove_child(drawn_card)
	
	# Keep track of how many have been drawn, and update texture accordingly
	cards_drawn += 1
	if cards_drawn == 3:
		print(cards_drawn)
	elif cards_drawn == 7:
		print(cards_drawn)
	elif cards_drawn == 12:
		print(cards_drawn)
		visible = false
	
	drawn_card.visible = true
	drawn_card.mouse_filter = MOUSE_FILTER_STOP
	drawn_card.get_node("TextureButton").mouse_filter = MOUSE_FILTER_STOP
	return drawn_card
	
