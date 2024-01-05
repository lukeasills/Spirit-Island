class_name dahan_raid
extends "res://cards/fear_cards/fear_card.gd"


func _ready():
	fear_card_on_ready()
	level1_effect_text = "Choose a land with Dahan. 1 Damage there."
	level2_effect_text = "Choose a land with Dahan. 1 Damage per Dahan there."
	level3_effect_text  = "Choose a land with Dahan. 2 Damage per Dahan there."

func resolve_level1_effects():
	var regions = get_land_with_dahan()
	var selected_land = await select_land(regions)
	if selected_land == null:
		return
	var selected_invader = await select_invaders_for_damage([selected_land])
	if selected_invader == null:
		return
	LabelContainer.set_text("Distribute 1 damage there.")
	await damage_invader(selected_invader["region"], selected_invader["token"], false)

func resolve_level2_effects():
	var regions = get_land_with_dahan()
	var selected_land = await select_land(regions)
	if selected_land == null:
		return
	var damage_to_deal = selected_land.dahans.size()
	while damage_to_deal > 0:
		LabelContainer.set_text(str("Distribute ", damage_to_deal, " damage there."))
		var selected_invader = await select_invaders_for_damage([selected_land])
		if selected_invader == null:
			return
		await damage_invader(selected_invader["region"], selected_invader["token"], false)
		damage_to_deal -= 1

func resolve_level3_effects():
	var regions = get_land_with_dahan()
	var selected_land = await select_land(regions)
	if selected_land == null:
		return
	var damage_to_deal = selected_land.dahans.size() * 2
	while damage_to_deal > 0:
		LabelContainer.set_text(str("Distribute ", damage_to_deal, " damage there."))
		var selected_invader = await select_invaders_for_damage([selected_land])
		if selected_invader == null:
			return
		await damage_invader(selected_invader["region"], selected_invader["token"], false)
		damage_to_deal -= 1
