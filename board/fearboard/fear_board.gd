extends Area2D

@export var CardEffectButton: Node

var is_focused
var is_in_motion

signal focused
signal unfocused

@export var speed: Vector2
@export var unfocused_position: Vector2
@export var focused_position: Vector2

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
	is_focused = false
	is_in_motion = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_in_motion:
		if is_focused && position.y < focused_position.y:
			position += speed
		if is_focused && position.y >= focused_position.y:
			position = focused_position
			is_in_motion = false
			focused.emit()
		if !is_focused && position.y > unfocused_position.y:
			position -= speed
		if !is_focused && position.y <= unfocused_position.y:
			position = unfocused_position
			is_in_motion = false
			unfocused.emit()
	

func generate_fear(how_much):
	var initially_focused = is_focused
	if !initially_focused:
		await set_focused()
	fear_generated.emit(how_much)
	for i in how_much:
		var is_empty = await $FearPool.generate_fear(true)
		if is_empty:
			await draw_fear_card()
			await $FearPool.reset_fear_pool()
	fear_generated_resolved.emit()
	if !initially_focused:
		await set_unfocused()

func draw_fear_card():
	fear_card_earned.emit()
	var new_fear_card = $FearDeck.draw()
	$FearCardTransformer.attach(new_fear_card)
	$FearCardTransformer.init_move($FearDeck.position, $EarnedFearCardsSpot.position)
	await $FearCardTransformer.transformed
	new_fear_card = $FearCardTransformer.detach()
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
		await get_tree().get_root().get_node("Main").resolve_fear_card(fear_card, fear_level)
		fear_card.queue_free()
	fear_cards_resolved.emit()

func set_focused():
	is_focused = true
	is_in_motion = true

func set_unfocused():
	is_focused = false
	is_in_motion = true

func set_lit():
	$HighlightPolygon.color.a = 0.25

func set_unlit():
	$HighlightPolygon.color.a = 0.1

func _on_mouse_entered():
	$HighlightPolygon.visible = true

func _on_mouse_exited():
	$HighlightPolygon.visible = false

func _on_input_event(viewport, event, shape_idx):
	if is_in_motion:
		return
	if (event is InputEventMouseButton && !event.pressed):
		if !is_focused:
			set_focused()
		else:
			set_unfocused()
