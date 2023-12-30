extends Node

@export var LandMap: Node

var fear_level

# Called when the node enters the scene tree for the first time.
func _ready():
	fear_level = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func generate_fear(how_much):
	for i in how_much:
		var is_empty = await $FearPool.generate_fear()
		if is_empty:
			await draw_fear_card()
			await $FearPool.reset_fear_pool()

func draw_fear_card():
	var new_fear_card = $FearDeck.draw()
	
	$FearCardMover.attach(new_fear_card)
	$FearCardMover.move($FearDeck.position, $EarnedFearCardsSpot.position)
	await $FearCardMover.moved
	new_fear_card = $FearCardMover.detach()
	$EarnedFearCardsSpot.attach(new_fear_card)

func resolve_earned_fear_cards():
	while !$EarnedFearCardsSpot.is_empty():
		var fear_card = $EarnedFearCardsSpot.get_oldest_card()
		await fear_card.reveal()
		await fear_card.resolve_effects(fear_level)
		fear_card = $EarnedFearCardsSpot.detach(fear_card)
		fear_card.queue_free()
