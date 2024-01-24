extends ReferenceRect

signal emptied

var cards_drawn
@export var card_loader: Resource
@export var terror_level_card: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	cards_drawn = 0
	setup_initial_deck()

func setup_initial_deck(level1=3, level2=3, level3=3):
	var cards = card_loader.get_cards(level3)
	for card in cards:
		add_child(card)
	var level3_card = terror_level_card.instantiate()
	level3_card.level = 3
	#level3_card.position.x = position.x - 40
	add_child(level3_card)
	cards = card_loader.get_cards(level2)
	for card in cards:
		add_child(card)
	var level2_card = terror_level_card.instantiate()
	level2_card.level = 2
	#level2_card.position.x = position.x - 40
	add_child(level2_card)
	cards = card_loader.get_cards(level1)
	for card in cards:
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
	
