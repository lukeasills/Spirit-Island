class_name dahan_enheartened
extends "res://cards/fear_cards/fear_card.gd"

func _ready():
	fear_card_on_ready()
	level1_effect_text = "You may Push 1 Dahan from a land with Invaders or Gather 1 Dahan into a land with Invaders."
	level2_effect_text = "Choose a land. In chosen land: Gather up to 2 Dahan, then 1 Damage if Dahan are present."
	level3_effect_text  = "Choose a land. In chosen land: Gather up to 2 Dahan, then 1 Damage per Dahan present."

func resolve_level1_effects(active_option=0):
	# Push option
	if active_option == 0:
		var regions = Main.get_land_with_invaders()
		var token_selection = await Main.select_dahan_for_removal(regions, false)#true)
		if token_selection == null || token_selection["skipped"]:
			return
		elif token_selection["option_selected"] && token_selection["option"] == 1:
			await resolve_level1_effects(token_selection["option"])
		else:
			for option in $Level1Options.get_children():
				option.disabled = true
			Main.get_node("LabelContainer").set_text("Select a destination.")
			regions = token_selection["token"].get_parent().get_parent().adjacent_regions
			var destination = await Main.select_land(regions, false)
			await Main.push_token(token_selection["token"], token_selection["token"].get_parent().get_parent(), destination["region"], false)
	# Gather option
	elif active_option == 1:
		var regions = Main.get_land_with_invaders()
		var regions_2 = []
		for region in regions:
			for adj in region.adjacent_regions:
				if adj.dahans.size() > 0:
					regions_2.append(region)
					break
		var region_selection  = await Main.select_land(regions_2, false)#true)
		if region_selection == null || region_selection["skipped"]:
			return
		elif region_selection["option_selected"] && region_selection["option"] == 0:
			await resolve_level1_effects(region_selection["option"])
		else:
			for option in $Level1Options.get_children():
				option.disabled = true
			Main.get_node("LabelContainer").set_text("Select a dahan.")
			Main.initiate_gather(region_selection["region"])
			var token_selection = await Main.select_dahan_for_removal(region_selection["region"].adjacent_regions, false)
			Main.resolve_gather()
			await Main.gather_token(token_selection["token"], token_selection["token"].get_parent().get_parent(), region_selection["region"], true)
		
func resolve_level2_effects(active_option=0):
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
	

func resolve_level3_effects(active_option=0):
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
