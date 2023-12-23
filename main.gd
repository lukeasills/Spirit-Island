extends Node
@export var blight_scene: PackedScene

var invader_deck_empty = false

signal explored
signal built
signal ravaged

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# On signal emit, explore the land type
func _on_invader_board_explore_initiated(land_types):
	await pre_invader_action_wait()
	var regions = $LandMap.get_children()
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
				if region.is_coastal || region.town_count + region.city_count > 0:
					await timed_invader_action(region, "add_explorer")
				# Else, if it is adjacent to a region with buildings, add an explorer
				else:
					for adj_region in region.adjacent_regions:
						if adj_region.town_count + adj_region.city_count > 0:
							await timed_invader_action(region, "add_explorer")
							break
	explored.emit()

# When the build space emits the "build" signal with the card's land_type
func _on_invader_board_build_initiated(land_types):
	await pre_invader_action_wait()
	var regions = $LandMap.get_children()
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
				var towns = region.town_count
				var cities = region.city_count
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
	var regions = $LandMap.get_children()
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
				damage = region.explorer_count + region.town_count*2 + region.city_count*3
			# If 2 or more damage, add a blight to the region
			if damage >= 2:
				await add_blight(region)
	ravaged.emit()

func pre_invader_action_wait():
	$InvaderActionTimer.start()
	await $InvaderActionTimer.timeout

func timed_invader_action(region, method):
	region.set_lit()
	region.call(method)
	$InvaderActionTimer.start()
	await $InvaderActionTimer.timeout
	region.set_unlit()

# Add blight to the region, cascading if one is already present
func add_blight(region):
	var had_blight = region.blight_count > 0
	await timed_invader_action(region, "add_blight")
	if had_blight:
		await cascade_blight(region)

func cascade_blight(region):
	var adjacent_regions = region.adjacent_regions
	var new_blight = blight_scene.instantiate()
	$LabelContainer.set_text("The blight cascades! Choose a region.")

	# Defer to function which prompts region selection and returns the region
	var cascading_region = await prompt_region_selection(adjacent_regions, new_blight)
	$LabelContainer.turn_off_text()
	await add_blight(cascading_region)

# Handles the logic for prompting a region choice
func prompt_region_selection(valid_regions, token_on_hover):
	for region in valid_regions:
		region.set_active()
	var selected_region = await $LandMap.active_region_selected
	for region in valid_regions:
		region.set_inactive()
	return selected_region

func _on_invader_deck_emptied():
	invader_deck_empty = true
