class_name wary_of_the_interior
extends "res://cards/fear_cards/fear_card.gd"


func _ready():
	fear_card_on_ready()
	level1_effect_text = "Remove 1 Explorer from an Inland land."
	level2_effect_text = "Remove 1 Explorer or Town from an Inland land."
	level3_effect_text  = "Remove 1 Explorer or Town from any land."

func resolve_level1_effects():
	var regions = get_inland_land()
	var selected = await select_invaders_for_removal(regions, true, false, false)
	if selected == null:
		return
	await remove_invader(selected["region"], selected["token"], false)

func resolve_level2_effects():
	var regions = get_inland_land()
	var selected = await select_invaders_for_removal(regions, true, true, false)
	if selected == null:
		return
	await remove_invader(selected["region"], selected["token"], false)

func resolve_level3_effects():
	var regions = get_any_land()
	var selected = await select_invaders_for_removal(regions, true, true, false)
	if selected == null:
		return
	await remove_invader(selected["region"], selected["token"], false)

