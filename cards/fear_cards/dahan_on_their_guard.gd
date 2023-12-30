class_name dahan_on_their_guard
extends "res://cards/fear_cards/fear_card_base.gd"

func resolve_level1_effects():
	var regions = get_any_land()
	await defend(regions, "per_dahan", 1)

func resolve_level2_effects():
	var regions = get_land_with_dahan()
	await defend(regions, "constant", 1)
	await defend(regions, "per_dahan", 1)

func resolve_level3_effects():
	var regions = get_any_land()
	await defend(regions, "per_dahan", 2)
