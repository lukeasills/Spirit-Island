extends Node
signal invader_actions_completed

signal ravage_initiated
signal build_initiated
signal explore_initiated

signal explored
signal built
signal ravaged

signal blight_cascade_initiated
signal blight_cascade_resolved

signal dahan_fight_back_initiated
signal dahan_fight_back_resolved

@export var LandMap: Node
@export var blight_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func initiate_invader_actions():
	# From ravage space to discard space
	var old_ravage_card = $RavageSpace.detach()
	# Check if there is something in RavageSpace...
	if old_ravage_card != null:
		$InvaderCardMover.attach(old_ravage_card)
		$InvaderCardMover.move($RavageSpace.position, $DiscardSpace.position)
		await $InvaderCardMover.moved	
		old_ravage_card = $InvaderCardMover.detach()
		$DiscardSpace.attach(old_ravage_card)
		
	# From build space to ravage space
	var old_build_card = $BuildSpace.detach()
	# Check if there is something in BuildSpace...
	if old_build_card != null:
		$InvaderCardMover.attach(old_build_card)
		$InvaderCardMover.move($BuildSpace.position, $RavageSpace.position)
		await $InvaderCardMover.moved
		old_build_card = $InvaderCardMover.detach()
		$RavageSpace.attach(old_build_card)
		await initiate_ravage(old_build_card.land_types)
	
	# From explore space to build space
	var old_explore_card = $ExploreSpace.detach()
	# Check if there is something in RavageSpace...
	if old_explore_card != null:
		$InvaderCardMover.attach(old_explore_card)
		$InvaderCardMover.move($ExploreSpace.position, $BuildSpace.position)
		await $InvaderCardMover.moved
		old_explore_card = $InvaderCardMover.detach( )
		print(old_explore_card)
		$BuildSpace.attach(old_explore_card)
		await initiate_build(old_explore_card.land_types)
	
	# From deck to explore space
	if !get_parent().invader_deck_empty:
		var drawn_card = $InvaderDeck.draw()
		$InvaderCardMover.attach(drawn_card)
		$InvaderCardMover.move($InvaderDeck.position, $ExploreSpace.position)
		await $InvaderCardMover.moved
		drawn_card = $InvaderCardMover.detach()
		$ExploreSpace.attach(drawn_card)
		await initiate_explore(drawn_card.land_types)
	invader_actions_completed.emit()
	get_tree().call_group("dahan", "reset_damage")
	get_tree().call_group("towns", "reset_damage")
	get_tree().call_group("cities", "reset_damage")
	
# Explore the land type
func initiate_explore(land_types):
	explore_initiated.emit()
	await pre_invader_action_wait()
	var regions = LandMap.get_children().slice(0,LandMap.get_children().size()-1)
	# Iterate through all land types on the card
	for land_type in land_types:
		explore_initiated.emit(land_type)
		# Iterate through all regions..
		for region in regions:
			var correct_type = false
			# If "Coastal" is the land type, then check if coastal
			if land_type == "Coasts":
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
func initiate_build(land_types):
	build_initiated.emit()
	await pre_invader_action_wait()
	var regions = LandMap.get_children().slice(0,LandMap.get_children().size()-1)
	for land_type in land_types:
		build_initiated.emit(land_type)
		# Iterate through all regions...
		for region in regions:
			var correct_type = false
			# If "Coastal" is the land type, then check if coastal
			if land_type == "Coasts":
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
func initiate_ravage(land_types):
	ravage_initiated.emit()
	await pre_invader_action_wait()
	var regions = LandMap.get_children().slice(0,LandMap.get_children().size()-1)
	for land_type in land_types:
		ravage_initiated.emit(land_type)
		# Iterate through all regions
		for region in regions:
			var correct_type = false
			# If "Coastal" is the land type, then check if coastal
			if land_type == "Coasts":
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
		await LandMap.destroy_dahan(region, region.dahans[0], true)
	# If any remain, see if the invaders damage 1
	# Prompt and allow player to choose 1 damage at a time 
	if region.dahans.size() > 0 && dahan_damaged:
		await LandMap.damage_dahan(region, region.dahans[0], true)

# Handles logic of destroying / damaging invaders
func dahan_fight_back(region):
	var damage = region.dahans.size() * 2
	while damage > 0:
		dahan_fight_back_initiated.emit(damage)
		var invader = await prompt_invader_selection(region)
		await LandMap.damage_invader(region, invader, false)
		damage -= 1
	dahan_fight_back_resolved.emit()

# Add blight to the region, cascading if one is already present
func invaders_damage_the_land(region):
	var had_blight = region.blights.size() > 0
	await timed_invader_action(region, "add_blight")
	if had_blight:
		await blight_cascades(region)

func blight_cascades(region):
	var adjacent_regions = region.adjacent_regions
	var new_blight = blight_scene.instantiate()
	blight_cascade_initiated.emit()

	# Defer to function which prompts region selection and returns the region
	var cascading_region = await prompt_region_selection(adjacent_regions, new_blight)
	blight_cascade_resolved.emit()
	await invaders_damage_the_land(cascading_region)

func prompt_invader_selection(region):	
	region.activate_invaders_for_damage()
	var selected_invader = await LandMap.active_token_selected
	region.deactivate_invaders()
	return selected_invader

# Handles the logic for prompting a region choice
func prompt_region_selection(valid_regions, token_on_hover):
	for region in valid_regions:
		region.set_active()
	var selected_region = await LandMap.active_region_selected
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

