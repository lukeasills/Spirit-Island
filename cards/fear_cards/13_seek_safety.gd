class_name seek_safety
extends "res://cards/fear_cards/fear_card.gd"

func _ready():
	fear_card_on_ready()
	level1_effect_text = "You may Push 1 Explorer into a land with more Towns and Cities than the land it came from."
	level2_effect_text = "You may Gather 1 Explorer into a land with Towns or Cities, or Gather 1 Town into a land with Cities."
	level3_effect_text  = "You may remove up to 3 Health worth of Invaders from a land without Cities."

func resolve_level1_effects():
	var regions = get_land_with_invaders()
	var valid_regions = []
	for region in regions:
		var adj_regions = region.adjacent_regions
		for adj in adj_regions:
			if adj.towns.size() + adj.cities.size() > region.towns.size() + region.cities.size():
				valid_regions.append(region) 
				break
	var token_selection = await select_invaders_for_removal(valid_regions, true, false, false, true)
	if token_selection == null || token_selection["skipped"]:
		return
	LabelContainer.set_text("Select a destination with more Towns and Cities than the land it came from.")
	var valid_destinations = []
	var source = token_selection["region"]
	for adj in source.adjacent_regions:
		if adj.towns.size() + adj.cities.size() > source.towns.size() + source.cities.size():
			valid_destinations.append(adj)
	var destination = await select_land(valid_destinations, false)
	await push_token(token_selection["token"], source, destination, false)

func resolve_level2_effects():
	var lands_with_invaders = get_land_with_invaders()
	var regions = []
	for land in lands_with_invaders:
		var city = land.cities.size() > 0
		var town_or_city = land.towns.size() > 0 || city
		if town_or_city:
			for adj in land.adjacent_regions:
				if city && adj.towns.size() > 0:
					regions.append(land)
					break
				elif adj.explorers.size() > 0:
					regions.append(land)
					break			
	var region_selection = await select_land(regions, true)
	if region_selection == null || region_selection["skipped"]:
		return
	var adjacent_regions = region_selection["region"].adjacent_regions
	var explorers = false
	var towns = false
	if region_selection["region"].cities.size() > 0:
		for adj in adjacent_regions:
			if adj.explorers.size() > 0:
				explorers = true
			if adj.towns.size() > 0:
				towns = true
			if explorers && towns:
				break
	else:
		for adj in adjacent_regions:
			if adj.explorers.size() > 0:
				explorers = true
				break
	var message = ""
	if explorers && towns:
		message = "You may Gather 1 Explorer or 1 Town."
	elif explorers:
		message = "You may Gather 1 Explorer."
	else:
		message = "You may Gather 1 Town."
	LabelContainer.set_text(message)
	var token_selection = await select_invaders_for_removal(adjacent_regions, explorers, towns, false, true)
	if token_selection == null || token_selection["skipped"]:
		return
	await gather_token(token_selection["token"], token_selection["region"], region_selection["region"],false)
	LabelContainer.turn_off_text()
	

func resolve_level3_effects():
	var regions = get_any_land()
	var valid_regions = []
	var health = 3
	for region in regions:
		if region.cities.size() == 0:
			valid_regions.append(region)
	var selection = await select_invaders_for_removal(valid_regions, true, true, false, true)
	if selection != null && !selection["skipped"]:
		var region = selection["region"]
		if region.explorers.has(selection["token"]):
			health -= 1
		elif region.towns.has(selection["token"]):
			health -= 2
		await remove_invader(selection["region"], selection["token"],false)
		LabelContainer.set_text(str("You may remove up to ", health, "more Health worth of Invaders from this land."))
		var towns = health == 2
		selection = await select_invaders_for_removal([region], true, towns, false, true)
		if selection != null && !selection["skipped"]:
			if region.explorers.has(selection["token"]):
				health -= 1
			else:
				health = 0
			await remove_invader(selection["region"], selection["token"],false)
			if health == 1:
				LabelContainer.set_text("You may remove up to 1 more Health worth of Invaders from this land.")
				selection = await select_invaders_for_removal([region], true, false, false, true)
				if selection != null && !selection["skipped"]:
					await remove_invader(selection["region"], selection["token"],false)
	LabelContainer.turn_off_text()
