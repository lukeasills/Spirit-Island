class_name isolation
extends "res://cards/fear_cards/fear_card.gd"

func _ready():
	fear_card_on_ready()
	level1_effect_text = "Remove 1 Explorer or Town from a land where it is the only Invader."
	level2_effect_text = "Remove 1 Explorer or Town from a land with 2 or fewer Invaders."
	level3_effect_text  = "Remove an Invader from a land with 2 or fewer Invaders."

func resolve_level1_effects():
	var regions = get_land_with_invaders("exactly", 1)
	var selected = await select_invaders_for_removal(regions, true, true, false)
	if selected == null:
		return
	await remove_invader(selected["region"], selected["token"], false)

func resolve_level2_effects():
	var regions = get_land_with_invaders("or fewer", 2)
	var selected = await select_invaders_for_removal(regions, true, true, false)
	if selected == null:
		return
	await remove_invader(selected["region"], selected["token"], false)

func resolve_level3_effects():
	var regions = get_land_with_invaders("or fewer", 2)
	var selected = await select_invaders_for_removal(regions, true, true, true)
	if selected == null:
		return
	await remove_invader(selected["region"], selected["token"], false)

