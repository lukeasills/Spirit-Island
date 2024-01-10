class_name retreat
extends "res://cards/fear_cards/fear_card.gd"

func _ready():
	fear_card_on_ready()
	level1_effect_text = "You may push up to 2 Explorers from an Inland land."
	level2_effect_text = "You may push up to 3 Explorers or Towns from an Inland land."
	level3_effect_text  = "You may push any number of Explorers or Towns from one land."

func resolve_level1_effects():
	# First...
	var regions = Main.get_inland_land()
	var token_selection = await Main.select_invaders_for_removal(regions, true, false, false, true)
	if token_selection == null || token_selection["skipped"]:
		return
	var source_region = token_selection["token"].get_parent().get_parent()
	Main.get_node("LabelContainer").set_text("Select a destination.")
	var region_selection = await Main.select_land(token_selection["token"].get_parent().get_parent().adjacent_regions, "invader", false)
	if region_selection == null:
		return
	await Main.push_token(token_selection["token"], token_selection["token"].get_parent().get_parent(), region_selection["region"], false)
	# Second...
	Main.get_node("LabelContainer").set_text("You may push up to 1 more Explorers from this land.")
	token_selection = await Main.select_invaders_for_removal([source_region], true, false, false, true)
	if token_selection == null || token_selection["skipped"]:
		return
	Main.get_node("LabelContainer").set_text("Select a destination.")
	region_selection = await Main.select_land(token_selection["token"].get_parent().get_parent().adjacent_regions, false, "invader")
	if region_selection == null:
		return
	await Main.push_token(token_selection["token"], source_region, region_selection["region"], false)
	Main.get_node("LabelContainer").turn_off_text()

func resolve_level2_effects():
	# First...
	var regions = Main.get_inland_land()
	var token_selection = await Main.select_invaders_for_removal(regions, true, true, false, true)
	if token_selection == null || token_selection["skipped"]:
		return
	Main.get_node("LabelContainer").set_text("Select a destination.")
	var source_region = token_selection["token"].get_parent().get_parent()
	var region_selection = await Main.select_land(source_region.adjacent_regions, false, "invader")
	if region_selection == null:
		return
	await Main.push_token(token_selection["token"], source_region, region_selection["region"], false)
	# Second...
	Main.get_node("LabelContainer").set_text("You may push up to 2 more Explorers / Towns from this land.")
	token_selection = await Main.select_invaders_for_removal([source_region], true, true, false, true)
	if token_selection == null || token_selection["skipped"]:
		return
	Main.get_node("LabelContainer").set_text("Select a destination.")
	region_selection = await Main.select_land(source_region.adjacent_regions, false, "invader")
	if region_selection == null:
		return
	await Main.push_token(token_selection["token"], source_region, region_selection["region"], false)
	Main.get_node("LabelContainer").turn_off_text()
	# Third...
	Main.get_node("LabelContainer").set_text("You may push up to 1 more Explorers / Towns from this land.")
	token_selection = await Main.select_invaders_for_removal([source_region], true, true, false, true)
	if token_selection == null || token_selection["skipped"]:
		return
	Main.get_node("LabelContainer").set_text("Select a destination.")
	region_selection = await Main.select_land(source_region.adjacent_regions, false, "invader")
	if region_selection == null:
		return
	await Main.push_token(token_selection["token"], source_region, region_selection["region"], false)
	Main.get_node("LabelContainer").turn_off_text()

func resolve_level3_effects():
	# First...
	var regions = Main.get_inland_land()
	var token_selection = await Main.select_invaders_for_removal(regions, true, true, false, true)
	if token_selection == null || token_selection["skipped"]:
		return
	var source_region = token_selection["token"].get_parent().get_parent()
	Main.get_node("LabelContainer").set_text("Select a destination.")
	var invader_type = "explorer"
	if source_region.towns.has(token_selection["token"]):
		invader_type = "town"
	var region_selection = await Main.select_land(source_region.adjacent_regions, false, invader_type)
	if region_selection == null:
		return
	await Main.push_token(token_selection["token"], source_region, region_selection["region"], false)
	var skipped = false
	# Let repeat any number of times
	while !skipped:
		Main.get_node("LabelContainer").set_text("You may push any number of Explorers / Towns from this land.")
		token_selection = await Main.select_invaders_for_removal([source_region], true, true, false, true)
		if token_selection == null || token_selection["skipped"]:
			skipped = true
			return
		invader_type = "explorer"
		if source_region.towns.has(token_selection["token"]):
			invader_type = "town"
		Main.get_node("LabelContainer").set_text("Select a destination.")
		region_selection = await Main.select_land(source_region.adjacent_regions, false, invader_type)
		if region_selection == null:
			return
		await Main.push_token(token_selection["token"], source_region, region_selection["region"], false)
		Main.get_node("LabelContainer").turn_off_text()
