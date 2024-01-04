class_name feat_of_the_unseen
extends "res://cards/fear_cards/fear_card.gd"

func _ready():
	fear_card_on_ready()
	level1_effect_text = "Remove 1 Explorer or Town from a land with a Holy Site."
	level2_effect_text = "Remove 1 Explorer or Town from a land with a Presence."
	level3_effect_text  = "Choose a land with a Presence. Remove 1 Explorer or Town, or 1 City if it is a land with a Holy Site."

func resolve_level1_effects():
	var regions = get_land_with_presence(true)
	var selection = await select_invaders_for_removal(regions, true, true, false)
	if selection == null:
		return
	await remove_invader(selection["region"], selection["token"], false)

func resolve_level2_effects():
	var regions = get_land_with_presence()
	var selection = await select_invaders_for_removal(regions, true, true, false)
	if selection == null:
		return
	await remove_invader(selection["region"], selection["token"], false)

# Not quite consistent with other selection rules... need to figure out how to handle OR
func resolve_level3_effects():
	var regions = get_land_with_presence()
	var region = await select_land(regions, false)
	if region == null:
		return
	if region.has_holy_site():
		LabelContainer.set_text("Remove 1 Explorer, Town, or City.")
		var selection = await select_invaders_for_removal([region], true, true, true, false)
		if selection == null:
			return
		await remove_invader(region, selection["token"], false)
	else:
		LabelContainer.set_text("Remove 1 Explorer or Town.")
		var selection = await select_invaders_for_removal([region], true, true, false, false)
		if selection == null:
			return
		await remove_invader(region, selection["token"], false)
	LabelContainer.turn_off_text()
