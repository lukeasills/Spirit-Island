class_name avoid_the_dahan
extends "res://cards/fear_cards/fear_card.gd"

func _ready():
	fear_card_on_ready()
	level1_effect_text = "Invaders do not Explore into lands with at least 2 Dahan."
	level2_effect_text = "Invaders do not Build in lands where Dahan outnumber Towns and Cities."
	level3_effect_text  = "Invaders do not Build in lands with Dahan."

func resolve_level1_effects(active_option=0):
	var regions = Main.get_land_with_dahan("at least", 2)
	await Main.block_invader_actions(regions, [true, false, false])

func resolve_level2_effects(active_option=0):
	var regions = Main.get_land_with_dahan()
	var regions_to_block = []
	for region in regions:
		if region.dahans.size() > region.towns.size() + region.cities.size():
			regions_to_block.append(region)
	await Main.block_invader_actions(regions_to_block, [false, [true, true], false])

func resolve_level3_effects(active_option=0):
	var regions = Main.get_land_with_dahan()
	await Main.block_invader_actions(regions, [false, [true, true], false])
