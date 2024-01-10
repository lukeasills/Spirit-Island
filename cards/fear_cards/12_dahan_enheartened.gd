class_name dahan_enheartened
extends "res://cards/fear_cards/fear_card.gd"

func _ready():
	fear_card_on_ready()
	level1_effect_text = "You may Push 1 Dahan from a land with Invaders or Gather 1 Dahan into a land with Invaders."
	level2_effect_text = "Choose a land. In chosen land: Gather up to 2 Dahan, then 1 Damage if Dahan are present."
	level3_effect_text  = "Choose a land. In chosen land: Gather up to 2 Dahan, then 1 Damage per Dahan present."

func resolve_level1_effects():
	# First...
	var regions = Main.get_land_with_invaders()
	var regions_2 = []
	for region in regions:
		var adjacent_regions = region.adjacent_regions
		for adjacent_region in adjacent_regions:
			if adjacent_region.dahans.size() > 0:
				regions_2.append(adjacent_region)
	regions.append_array(regions_2)
	var token_selection = await Main.select_dahan_for_removal(regions, true)
	if token_selection == null || token_selection["skipped"]:
		return
	Main.get_node("LabelContainer").set_text("Select a destination.")
	# If a push...
	if token_selection["token"].get_parent().get_parent().has_invaders():
		regions = token_selection["token"].get_parent().get_parent().adjacent_regions
		var destination = await Main.select_land(regions, false)
		await Main.push_token(token_selection["token"], token_selection["token"].get_parent().get_parent(), destination["region"], false)
	# If a gather...
	else:
		regions = token_selection["token"].get_parent().get_parent().adjacent_regions
		var valid_destinations = []
		for region in regions:
			if region.has_invaders():
				valid_destinations.append(region)
		var destination = await Main.select_land(valid_destinations, false)
		await Main.gather_token(token_selection["token"], token_selection["token"].get_parent().get_parent(), destination["region"], false)
	
func resolve_level2_effects():
	var regions = Main.get_any_land()
	var chosen_land = await Main.select_land(regions, false)
	Main.get_node("LabelContainer").set_text("Gather up to 2 Dahan, then 1 Damage if Dahan are present.")
	var adj_regions = chosen_land["region"].adjacent_regions
	var selection = await Main.select_dahan_for_removal(adj_regions, true)
	# Only prompt again if selected already...
	if selection != null && !selection["skipped"]:
		await Main.gather_token(selection["token"], selection["token"].get_parent().get_parent(), chosen_land["region"], false)
		# Second...
		selection = await Main.select_dahan_for_removal(adj_regions, true)
		if selection != null || !selection["skipped"]:
			await Main.gather_token(selection["token"], selection["token"].get_parent().get_parent(), chosen_land["region"], false)
	if chosen_land.dahans.size() > 0:
		Main.get_node("LabelContainer").set_text("Distribute 1 Damage.")
		selection = await Main.select_invaders_for_damage([chosen_land["region"]], true, true, true, false)
		await Main.damage_invader(selection["token"].get_parent().get_parent(), selection["token"],false)
	Main.get_node("LabelContainer").turn_off_text()
	

func resolve_level3_effects():
	var regions = Main.get_any_land()
	var chosen_land = await Main.select_land(regions, false)
	Main.get_node("LabelContainer").set_text("Gather up to 2 Dahan, then 1 Damage per Dahan present.")
	var adj_regions = chosen_land["region"].adjacent_regions
	var selection = await Main.select_dahan_for_removal(adj_regions, true)
	# Only prompt again if selected already...
	if selection != null && !selection["skipped"]:
		await Main.gather_token(selection["token"], selection["token"].get_parent().get_parent(), chosen_land["region"], false)
		# Second...
		selection = await Main.select_dahan_for_removal(adj_regions, true)
		if selection != null && !selection["skipped"]:
			await Main.gather_token(selection["token"], selection["token"].get_parent().get_parent(), chosen_land["region"], false)
	if chosen_land["region"].dahans.size() > 0:
		var damage = chosen_land["region"].dahans.size()
		while damage > 0 && chosen_land["region"].has_invaders():
			Main.get_node("LabelContainer").set_text(str("Distribute ",damage," Damage."))
			selection = await Main.select_invaders_for_damage([chosen_land["region"]], true, true, true, false)
			await Main.damage_invader(selection["token"].get_parent().get_parent(), selection["token"],false)
			damage -= 1
	Main.get_node("LabelContainer").turn_off_text()
