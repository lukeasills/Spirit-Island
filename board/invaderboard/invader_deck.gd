extends MarginContainer

@export var card_back_texture: Texture

signal emptied

var cards_drawn
var current_stage_cards

# Called when the node enters the scene tree for the first time.
func _ready():
	$DeckButton.texture_normal = card_back_texture
	cards_drawn = 0
	current_stage_cards = $Stage1Cards

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# On button press, 'pop' the top card data, and instantiate a new card
# Emit the new card to be listened to by main
func draw():
	# Get a random card from the current stage
	var random_card_index = randi() % current_stage_cards.get_child_count()
	var drawn_card = current_stage_cards.get_children()[random_card_index]
	current_stage_cards.remove_child(drawn_card)
	
	# Keep track of how many have been drawn, and update texture accordingly
	cards_drawn += 1
	if cards_drawn == 4:
		current_stage_cards = $Stage2Cards
		update_back(2)
	elif cards_drawn == 9:
		current_stage_cards = $Stage3Cards
		update_back(3)
	elif cards_drawn == 15:
		visible = false
		emptied.emit()
	
	drawn_card.visible = true
	return drawn_card

# Update the texture of the button to reflect higher stage cards
func update_back(new_stage):
	var path = str("res://art/cards/invaders/backs/Invader",new_stage,"CardBack.png")
	$DeckButton.texture_normal = load(path)
	