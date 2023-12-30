extends Node
@export var blight_scene: PackedScene

var invader_deck_empty = false

signal explored
signal built
signal ravaged

var turn_complete
var invader_actions_ongoing

# Called when the node enters the scene tree for the first time.
func _ready():
	turn_complete = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_SPACE:
			if turn_complete:
				turn_complete = false
				await $FearBoard.resolve_earned_fear_cards()
				invader_actions_ongoing = false
				$InvaderBoard.initiate_invader_actions()

# On signal emit, explore the land type
func _on_invader_board_explore_initiated(land_types):
	await pre_invader_action_wait()
	var regions = $LandMap.get_children().slice(0,$LandMap.get_children().size()-1)
	# Iterate through all land types on the card
	for land_type in land_types:
		# Iterate through all regions..
		for region in regions:
			var correct_type = false
			# If "Coastal" is the land type, then check if coastal
			if land_type == "Coastal":
				correct_type = region.is_coastal
			# Else, ID the land type
			elif region.land_type == land_type:
				correct_type = region.land_type == land_type
			# If the type matches...
			if correct_type:
				# If it is coastal or has buildings, add an explorer
				if region.is_coastal || region.towns.size() + region.cities.size() > 0:
					await timed_invader_action(region, "add_explorer")
				# Else, if it is adjacent to a region with buildings, add an explorer
				else:
					for adj_region in region.adjacent_regions:
						if adj_region.towns.size() + adj_region.cities.size() > 0:
							await timed_invader_action(region, "add_explorer")
							break
	explored.emit()

# When the build space emits the "build" signal with the card's land_type
func _on_invader_board_build_initiated(land_types):
	await pre_invader_action_wait()
	var regions = $LandMap.get_children().slice(0,$LandMap.get_children().size()-1)
	for land_type in land_types:
		# Iterate through all regions...
		for region in regions:
			var correct_type = false
			# If "Coastal" is the land type, then check if coastal
			if land_type == "Coastal":
				correct_type = region.is_coastal
			# Else, ID the land type
			elif region.land_type == land_type:
				correct_type = region.land_type == land_type
				
			# If it is the correct land_type & has some kind of invader...
			if correct_type && region.has_invaders():
				var towns = region.towns.size()
				var cities = region.cities.size()
				# If more towns than cities, add a city

				if towns > cities:
					await timed_invader_action(region, "add_city")
				# Else, add a town
				else:
					await timed_invader_action(region, "add_town")
	built.emit()

# When the ravage space emits the "ravage" signal wtih the card's land_type
func _on_invader_board_ravage_initiated(land_types):
	await pre_invader_action_wait()
	var regions = $LandMap.get_children().slice(0,$LandMap.get_children().size()-1)
	for land_type in land_types:
		# Iterate through all regions
		for region in regions:
			var correct_type = false
			# If "Coastal" is the land type, then check if coastal
			if land_type == "Coastal":
				correct_type = region.is_coastal
			# Else, ID the land type
			elif region.land_type == land_type:
				correct_type = region.land_type == land_type
			
			var damage = 0
			# If correct land_type and has invaders
			if correct_type && region.has_invaders():
				# Sum up the damage dealt: 1 per explorer, 2 per town, 3 per city
				damage += region.explorers.size() 
				damage += region.towns.size()*2 
				damage += region.cities.size()*3
			
			# Don't even continue if damage is 0...
			if damage == 0:
				continue
				
			# If 2 or more damage, invaders add blight
			if damage >= 2:
				await invaders_damage_the_land(region)
			
			if region.dahans.size() > 0:
				# If region has dahan, resolve damage to them
				await invaders_fight_dahan(region, damage)
				# If dahan remain, they fight back!
				if region.dahans.size() > 0:
					await dahan_fight_back(region)
	ravaged.emit()

# Handles logic of destroying / damaging dahan
func invaders_fight_dahan(region, damage):
	# 2 damage destroyes a dahan...
	var dahan_destroyed = floor(damage / 2)
	var dahan_damaged = damage % 2 == 1
	for num in dahan_destroyed:
		# Stop if past the total number of dahan in the region
		if num >= region.dahans.size():
			break
		await $LandMap.destroy_dahan(region, region.dahans[0], true)
	# If any remain, see if the invaders damage 1
	# Prompt and allow player to choose 1 damage at a time 
	if region.dahans.size() > 0 && dahan_damaged:
		await $LandMap.damage_dahan(region, region.dahans[0], true)

# Handles logic of destroying / damaging invaders
func dahan_fight_back(region):
	var damage = region.dahans.size() * 2
	while damage > 0:
		$LabelContainer.set_text(str("The Dahan fight back! Distribute ",damage," damage"))
		var invader = await prompt_invader_selection(region)
		await $LandMap.damage_invader(region, invader, false)
		damage -= 1
	$LabelContainer.turn_off_text()

# Add blight to the region, cascading if one is already present
func invaders_damage_the_land(region):
	var had_blight = region.blights.size() > 0
	await timed_invader_action(region, "add_blight")
	if had_blight:
		await blight_cascades(region)

func blight_cascades(region):
	var adjacent_regions = region.adjacent_regions
	var new_blight = blight_scene.instantiate()
	$LabelContainer.set_text("The blight cascades! Choose a region.")

	# Defer to function which prompts region selection and returns the region
	var cascading_region = await prompt_region_selection(adjacent_regions, new_blight)
	$LabelContainer.turn_off_text()
	await invaders_damage_the_land(cascading_region)

func prompt_invader_selection(region):	
	region.activate_invaders_for_damage()
	var selected_invader = await $LandMap.active_token_selected
	region.deactivate_invaders()
	return selected_invader

# Handles the logic for prompting a region choice
func prompt_region_selection(valid_regions, token_on_hover):
	for region in valid_regions:
		region.set_active()
	var selected_region = await $LandMap.active_region_selected
	for region in valid_regions:
		region.set_inactive()
	return selected_region

func pre_invader_action_wait():
	$InvaderActionTimer.start()
	await $InvaderActionTimer.timeout

func timed_invader_action(region, method):
	region.set_lit()
	region.call(method)
	$InvaderActionTimer.start()
	await $InvaderActionTimer.timeout
	region.set_unlit()

func _on_invader_deck_emptied():
	invader_deck_empty = true

func _on_invader_board_invader_actions_completed():
	invader_actions_ongoing = false
	turn_complete = true
