class_name trade_suffers
extends "res://cards/fear_cards/fear_card.gd"

func _ready():
	fear_card_on_ready()
	level1_effect_text = "Invaders do not Build in lands with Cities."
	level2_effect_text = "You may replace 1 Town with 1 Explorer in a Coastal land."
	level3_effect_text  = "You may replace 1 City with 1 Town, or 1 Town with 1 Explorer in a Coastal land."

func resolve_level1_effects():
	var regions = get_land_with_cities()
	await block_invader_actions(regions, [false, [true, true], false])

func resolve_level2_effects():
	var regions = get_coastal_land()
	var selection = await select_invaders_for_removal(regions, false, true, false, true)
	if selection == null || selection["skipped"]:
		return
	var region = selection["region"]
	await remove_invader(region, selection["token"], false)
	await region.add_explorer()

func resolve_level3_effects():
	var regions = get_coastal_land()
	var selection = await select_invaders_for_removal(regions, false, true, true, true)
	if selection == null || selection["skipped"]:
		return
	var region = selection["region"]
	if region.towns.has(selection["token"]):
		await remove_invader(region, selection["token"], false)
		await region.add_explorer()
	else:
		await remove_invader(region, selection["token"], false)
		await region.add_town()
