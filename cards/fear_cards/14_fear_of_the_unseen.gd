class_name feat_of_the_unseen
extends "res://cards/fear_cards/fear_card.gd"

func _ready():
	fear_card_on_ready()
	level1_effect_text = "Remove 1 Explorer or Town from a land with a Holy Site."
	level2_effect_text = "Remove 1 Explorer or Town from a land with a Presence."
	level3_effect_text  = "Choose a land with a Presence. Remove 1 Explorer or Town, or 1 City if it is a land with a Holy Site."

func resolve_level1_effects(active_option=0):
	var regions = Main.get_land_with_presence(true)
	var selection = await Main.select_invaders_for_removal(regions, true, true, false)
	if selection == null:
		return
	await Main.remove_invader(selection["token"].get_parent().get_parent(), selection["token"], false)

func resolve_level2_effects(active_option=0):
	var regions = Main.get_land_with_presence()
	var selection = await Main.select_invaders_for_removal(regions, true, true, false)
	if selection == null:
		return
	await Main.remove_invader(selection["token"].get_parent().get_parent(), selection["token"], false)

# Not quite consistent with other selection rules... need to figure out how to handle OR
func resolve_level3_effects(active_option=0):
	var regions = Main.get_land_with_presence()
	var region = await Main.select_land(regions, false)
	if region == null:
		return
	if region["region"].has_holy_site():
		Main.get_node("LabelContainer").set_text("Remove 1 Explorer, Town, or City.")
		var selection = await Main.select_invaders_for_removal([region["region"]], true, true, true, false)
		if selection == null:
			return
		await Main.remove_invader(region["region"], selection["token"], false)
	else:
		Main.get_node("LabelContainer").set_text("Remove 1 Explorer or Town.")
		var selection = await Main.select_invaders_for_removal([region["region"]], true, true, false, false)
		if selection == null:
			return
		await Main.remove_invader(region["region"], selection["token"], false)
	Main.get_node("LabelContainer").turn_off_text()
