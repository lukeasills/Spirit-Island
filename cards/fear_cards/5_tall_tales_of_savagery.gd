class_name tall_tales_of_savagery
extends "res://cards/fear_cards/fear_card.gd"

func _ready():
	fear_card_on_ready()
	level1_effect_text = "Remove 1 Explorer from a land with Dahan."
	level2_effect_text = "Remove 2 Explorers or 1 Town from a land with Dahan."
	level3_effect_text  = "Remove 2 Explorers or 1 Town from each land with Dahan. Then, remove 1 City from each land with at least 2 Dahan."

func resolve_level1_effects(active_option=0):
	var regions = Main.get_land_with_dahan()
	var selected = await Main.select_invaders_for_removal(regions, true, false, false)
	if selected == null:
		return
	await Main.remove_invader(selected["token"].get_parent().get_parent(), selected["token"], false)

func resolve_level2_effects(active_option=0):
	var regions = Main.get_land_with_dahan()
	var selected = await Main.select_invaders_for_removal(regions, true, true, false)
	if selected == null:
		return
	var region = selected["token"].get_parent().get_parent()
	# If it is an explorer, set up the player to choose a second explorer
	if region.explorers.has(selected):
		await Main.remove_invader(region, selected["token"], false)
		Main.get_node("LabelContainer").set_text("Remove 1 more Explorer.")
		selected = await Main.select_invaders_for_removal([region], true, false, false)
		if selected == null:
			Main.get_node("LabelContainer").turn_off_text()
			return
		await Main.remove_invader(region, selected["token"], false)
	# Else remove the town
	else:
		await Main.remove_invader(region, selected["token"], false)

func resolve_level3_effects(active_option=0):
	var regions = Main.get_land_with_dahan()
	# For each region
	for region in regions:
		Main.get_node("LabelContainer").set_text("Remove 2 Explorers or 1 Town from each land with Dahan.")
		var selected = await Main.select_invaders_for_removal([region], true, true, false)
		if selected == null:
			return
		# If it is an explorer, set up the player to choose a second explorer
		if region.explorers.has(selected):
			await Main.remove_invader(region, selected["token"], false)
			Main.get_node("LabelContainer").set_text("Remove 1 more Explorer.")
			selected = await Main.select_invaders_for_removal([region], true, false, false)
			if selected == null:
				Main.get_node("LabelContainer").turn_off_text()
				return
			await Main.remove_invader(region, selected["token"], false)
		# Else, remove the town
		else:
			await Main.remove_invader(region, selected["token"], false)
	regions = Main.get_land_with_dahan("at least", 2)
	# For each region with 2 Dahan
	for region in regions:
		Main.get_node("LabelContainer").set_text("Remove 1 City from each land with at least 2 Dahan.")
		var selected = await Main.select_invaders_for_removal([region], false, false, false)
		if selected == null:
			return
		await Main.remove_invader(region, selected["token"], false)
