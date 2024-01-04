class_name dahan_on_their_guard
extends "res://cards/fear_cards/fear_card.gd"

func _ready():
	level1_effect_text = "In each land, Defend 1 per Dahan"
	level2_effect_text = "In each land with Dahan, Defend 1, plus an additional Defend 1 per Dahan"
	level3_effect_text  = "In each land, Defend 2 per Dahan"

func resolve_level1_effects():
	var regions = get_land_with_dahan()
	await defend(regions, "per_dahan", 1)

func resolve_level2_effects():
	var regions = get_land_with_dahan()
	await defend(regions, "constant", 1)
	await defend(regions, "per_dahan", 1)

func resolve_level3_effects():
	var regions = get_any_land()
	await defend(regions, "per_dahan", 2)
