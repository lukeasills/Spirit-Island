extends Node

@export var LandMap: Node

var fear_level
signal initiate_resolve_earned_fear_cards
signal fear_cards_resolved

signal fear_generated
signal fear_generated_resolved
signal fear_card_earned
signal fear_card_earned_resolved

# Called when the node enters the scene tree for the first time.
func _ready():
	fear_level = 3


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func generate_fear(how_much):
	fear_generated.emit(how_much)
	for i in how_much:
		var is_empty = await $FearPool.generate_fear(true)
		if is_empty:
			await draw_fear_card()
			await $FearPool.reset_fear_pool()
	fear_generated_resolved.emit()

func draw_fear_card():
	fear_card_earned.emit()
	var new_fear_card = $FearDeck.draw()
	$FearCardMover.attach(new_fear_card)
	$FearCardMover.move($FearDeck.position, $EarnedFearCardsSpot.position)
	await $FearCardMover.moved
	new_fear_card = $FearCardMover.detach()
	$EarnedFearCardsSpot.attach(new_fear_card)
	fear_card_earned_resolved.emit()

func resolve_earned_fear_cards(is_delayed):
	if !$EarnedFearCardsSpot.is_empty():
		initiate_resolve_earned_fear_cards.emit()
	while !$EarnedFearCardsSpot.is_empty():
		var fear_card = $EarnedFearCardsSpot.get_oldest_card()
		fear_card.activate()
		fear_card = await $EarnedFearCardsSpot.fear_card_pressed
		fear_card.deactivate()
		await fear_card.reveal()
		if is_delayed:
			$FearCardTimer.start()
			await $FearCardTimer.timeout
		await fear_card.resolve_effects(fear_level)
		fear_card = $EarnedFearCardsSpot.detach(fear_card)
		fear_card.queue_free()
	fear_cards_resolved.emit()
