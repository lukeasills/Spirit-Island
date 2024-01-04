class_name retreat
extends "res://cards/fear_cards/fear_card.gd"

func _ready():
	fear_card_on_ready()
	level1_effect_text = "You may push up to 2 Explorers from an Inland land."
	level2_effect_text = "You may push up to 3 Explorers or Towns from an Inland land."
	level3_effect_text  = "You may push any number of Explorers or Towns from one land."

func resolve_level1_effects():
	# First...
	var regions = get_inland_land()
	var token_selection = await select_invaders_for_removal(regions, true, false, false, true)
	if token_selection == null || token_selection["skipped"]:
		return
	LabelContainer.set_text("Select a destination.")
	print(token_selection["region"])
	var region_selection = await select_land(token_selection["region"].adjacent_regions, false)
	if region_selection == null:
		return
	await push_token(token_selection["token"], token_selection["region"], region_selection, false)
	# Second...
	LabelContainer.set_text("You may push up to 1 more Explorers from this land.")
	token_selection = await select_invaders_for_removal([token_selection["region"]], true, false, false, true)
	if token_selection == null || token_selection["skipped"]:
		return
	LabelContainer.set_text("Select a destination.")
	region_selection = await select_land(token_selection["region"].adjacent_regions, false)
	if region_selection == null:
		return
	await push_token(token_selection["token"], token_selection["region"], region_selection, false)
	LabelContainer.turn_off_text()

func resolve_level2_effects():
	# First...
	var regions = get_inland_land()
	var token_selection = await select_invaders_for_removal(regions, true, true, false, true)
	if token_selection == null || token_selection["skipped"]:
		return
	LabelContainer.set_text("Select a destination.")
	print(token_selection["region"])
	var region_selection = await select_land(token_selection["region"].adjacent_regions, false)
	if region_selection == null:
		return
	await push_token(token_selection["token"], token_selection["region"], region_selection, false)
	# Second...
	LabelContainer.set_text("You may push up to 2 more Explorers / Towns from this land.")
	token_selection = await select_invaders_for_removal([token_selection["region"]], true, true, false, true)
	if token_selection == null || token_selection["skipped"]:
		return
	LabelContainer.set_text("Select a destination.")
	region_selection = await select_land(token_selection["region"].adjacent_regions, false)
	if region_selection == null:
		return
	await push_token(token_selection["token"], token_selection["region"], region_selection, false)
	LabelContainer.turn_off_text()
	# Third...
	LabelContainer.set_text("You may push up to 1 more Explorers / Towns from this land.")
	token_selection = await select_invaders_for_removal([token_selection["region"]], true, true, false, true)
	if token_selection == null || token_selection["skipped"]:
		return
	LabelContainer.set_text("Select a destination.")
	region_selection = await select_land(token_selection["region"].adjacent_regions, false)
	if region_selection == null:
		return
	await push_token(token_selection["token"], token_selection["region"], region_selection, false)
	LabelContainer.turn_off_text()

func resolve_level3_effects():
	# First...
	var regions = get_inland_land()
	var token_selection = await select_invaders_for_removal(regions, true, true, false, true)
	if token_selection == null || token_selection["skipped"]:
		return
	LabelContainer.set_text("Select a destination.")
	print(token_selection["region"])
	var region_selection = await select_land(token_selection["region"].adjacent_regions, false)
	if region_selection == null:
		return
	await push_token(token_selection["token"], token_selection["region"], region_selection, false)
	var skipped = false
	# Let repeat any number of times
	while !skipped:
		LabelContainer.set_text("You may push any number of Explorers / Towns from this land.")
		token_selection = await select_invaders_for_removal([token_selection["region"]], true, true, false, true)
		if token_selection == null || token_selection["skipped"]:
			skipped = true
			return
		LabelContainer.set_text("Select a destination.")
		region_selection = await select_land(token_selection["region"].adjacent_regions, false)
		if region_selection == null:
			return
		await push_token(token_selection["token"], token_selection["region"], region_selection, false)
		LabelContainer.turn_off_text()
