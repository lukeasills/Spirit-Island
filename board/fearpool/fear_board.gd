extends Node

@export var LandMap: Node
@export var ActiveCardSpace: Node
@export var CardEffectButton: Node

var fear_level
signal initiate_resolve_earned_fear_cards
signal fear_cards_resolved

signal fear_generated
signal fear_generated_resolved
signal fear_card_earned
signal fear_card_earned_resolved

# Called when the node enters the scene tree for the first time.
func _ready():
	fear_level = 1


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
		fear_card = $EarnedFearCardsSpot.detach(fear_card)
		ActiveCardSpace.attach_fear_card(fear_card)
		ActiveCardSpace.highlight_fear_level(fear_level)
		await prompt_card_effect_button()
		await fear_card.resolve_effects(fear_level)
		ActiveCardSpace.unhighlight_fear_level()
		fear_card = ActiveCardSpace.detach_card()
		fear_card.queue_free()
	fear_cards_resolved.emit()

func prompt_card_effect_button():
	CardEffectButton.visible = true
	CardEffectButton.disabled = false
	CardEffectButton.text = "Continue"
	await CardEffectButton.pressed
	CardEffectButton.visible = false
	CardEffectButton.disabled = true
