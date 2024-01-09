class_name belief_takes_root
extends "res://cards/fear_cards/fear_card.gd"

func _ready():
	fear_card_on_ready()
	level1_effect_text = "Defend 2 in all lands with a Presence."
	level2_effect_text = "Defend 2 in all lands with a Presence. Gain 1 Energy per Holy Site you have in lands with Invaders."
	level3_effect_text  = "Choose a land and remove up to 2 Health worth of Invaders per Presence there."

func resolve_level1_effects():
	var regions = Main.get_land_with_presence(false)
	await Main.defend(regions, "constant", 2)

func resolve_level2_effects():
	var regions = Main.get_land_with_presence(false)
	await Main.defend(regions, "constant", 2)
	regions = Main.get_land_with_presence(true)
	var gained_energy = 0
	for region in regions:
		if region.has_invaders():
			gained_energy += 1
	print(str("Gained ",gained_energy, " energy."))

# Not quite consistent with other selection rules... need to figure out how to handle OR
func resolve_level3_effects():
	var regions = Main.get_land_with_presence()
	var region = await Main.select_land(regions, false)
	if region == null:
		return
	var health = region.get_presence().amount * 2
	while health > 0:
		var towns = health > 1
		var cities = health > 2
		Main.get_node("LabelContainer").set_text(str("Remove up to ",health," Health worth of Invaders here."))
		var selection = await Main.select_invaders_for_removal([region], true, towns, cities, true)
		if selection == null || selection["skipped"]:
			return
		health -= 1
		if region.towns.has(selection["token"]):
			health -= 1
		elif region.cities.has(selection["token"]):
			health -= 2
		if health < 0:
			health = 0
		await Main.remove_invader(region, selection["token"], false)
	Main.get_node("LabelContainer").turn_off_text()
