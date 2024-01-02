extends Node

var invader_deck_empty = false

var turn_in_progress

# Called when the node enters the scene tree for the first time.
func _ready():
	turn_in_progress = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_SPACE:
			if !turn_in_progress:
				await initiate_main_turn_loop()

func initiate_main_turn_loop():
	turn_in_progress = true
	await $FearBoard.resolve_earned_fear_cards(true)
	await $InvaderBoard.initiate_invader_actions()

func _on_invader_deck_emptied():
	invader_deck_empty = true

func _on_invader_board_invader_actions_completed():
	turn_in_progress = false
