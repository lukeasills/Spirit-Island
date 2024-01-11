class_name seek_safety
extends "res://cards/fear_cards/fear_card.gd"

func _ready():
	fear_card_on_ready()
	level1_effect_text = "You may Push 1 Explorer into a land with more Towns and Cities than the land it came from."
	level2_effect_text = "You may Gather 1 Explorer into a land with Towns or Cities, or Gather 1 Town into a land with Cities."
	level3_effect_text  = "You may remove up to 3 Health worth of Invaders from a land without Cities."

func resolve_level1_effects(active_option=0):
	var regions = Main.get_land_with_invaders()
	var valid_regions = []
	for region in regions:
		var adj_regions = region.adjacent_regions
		for adj in adj_regions:
			if adj.towns.size() + adj.cities.size() > region.towns.size() + region.cities.size():
				valid_regions.append(region) 
				break
	var token_selection = await Main.select_invaders_for_removal(valid_regions, true, false, false, true)
	if token_selection == null || token_selection["skipped"]:
		return
	Main.get_node("LabelContainer").set_text("Select a destination with more Towns and Cities than the land it came from.")
	var valid_destinations = []
	var source = token_selection["token"].get_parent().get_parent()
	for adj in source.adjacent_regions:
		if adj.towns.size() + adj.cities.size() > source.towns.size() + source.cities.size():
			valid_destinations.append(adj)
	var destination = await Main.select_land(valid_destinations, false, "explorer")
	await Main.push_token(token_selection["token"], source, destination["region"], false)

func resolve_level2_effects(active_option=0):
	if active_option == 0:
		var lands_with_invaders = Main.get_land_with_invaders()
		var regions = []
		for land in lands_with_invaders:
			if land.cities.size() > 0 || land.towns.size() > 0:
				regions.append(land)
		var region_selection = await Main.select_land(regions, true)
		if region_selection == null || region_selection["skipped"]:
			return
		elif region_selection["option_selected"] && region_selection["option"] == 1:
			await resolve_level2_effects(1)
		else:
			Main.initiate_gather(region_selection["region"])
			var adjacent_regions = region_selection["region"].adjacent_regions
			var token_selection = await Main.select_invaders_for_removal(adjacent_regions, true, false, false, true)
			Main.resolve_gather()
			if token_selection == null || token_selection["skipped"]:
				pass
			elif region_selection["option_selected"] && region_selection["option"] == 1:
				await resolve_level2_effects(1)
			else:
				for option in $Level2Options.get_children():
					option.disabled = true
				await Main.gather_token(token_selection["token"], token_selection["token"].get_parent().get_parent(), region_selection["region"],false)
	else:
		var lands_with_invaders = Main.get_land_with_invaders()
		var regions = []
		for land in lands_with_invaders:
			if land.cities.size() > 0:
				regions.append(land)
		var region_selection = await Main.select_land(regions, true)
		if region_selection == null || region_selection["skipped"]:
			return
		elif region_selection["option_selected"] && region_selection["option"] == 0:
			await resolve_level2_effects(0)
		else:
			Main.initiate_gather(region_selection["region"])
			var adjacent_regions = region_selection["region"].adjacent_regions
			var token_selection = await Main.select_invaders_for_removal(adjacent_regions, false, true, false, true)
			Main.resolve_gather()
			if token_selection == null || token_selection["skipped"]:
				pass
			elif region_selection["option_selected"] && region_selection["option"] == 1:
				await resolve_level2_effects(0)
			else:
				for option in $Level2Options.get_children():
					option.disabled = true
				await Main.gather_token(token_selection["token"], token_selection["token"].get_parent().get_parent(), region_selection["region"],false)
	Main.get_node("LabelContainer").turn_off_text()
	

func resolve_level3_effects(active_option=0):
	var regions = Main.get_any_land()
	var valid_regions = []
	var health = 3
	for region in regions:
		if region.cities.size() == 0:
			valid_regions.append(region)
	var selection = await Main.select_invaders_for_removal(valid_regions, true, true, false, true)
	if selection != null && !selection["skipped"]:
		var region = selection["token"].get_parent().get_parent()
		if region.explorers.has(selection["token"]):
			health -= 1
		elif region.towns.has(selection["token"]):
			health -= 2
		await Main.remove_invader(selection["token"].get_parent().get_parent(), selection["token"],false)
		Main.get_node("LabelContainer").set_text(str("You may remove up to ", health, "more Health worth of Invaders from this land."))
		var towns = health == 2
		selection = await Main.select_invaders_for_removal([region], true, towns, false, true)
		if selection != null && !selection["skipped"]:
			if region.explorers.has(selection["token"]):
				health -= 1
			else:
				health = 0
			await Main.remove_invader(selection["token"].get_parent().get_parent(), selection["token"],false)
			if health == 1:
				Main.get_node("LabelContainer").set_text("You may remove up to 1 more Health worth of Invaders from this land.")
				selection = await Main.select_invaders_for_removal([region], true, false, false, true)
				if selection != null && !selection["skipped"]:
					await Main.remove_invader(selection["token"].get_parent().get_parent(), selection["token"],false)
	Main.get_node("LabelContainer").turn_off_text()
