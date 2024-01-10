extends Area2D
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

var Main

var is_focused
var is_in_motion
signal focused
signal unfocused

@export var speed: Vector2
@export var unfocused_position: Vector2
@export var focused_position: Vector2

@export var blight_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	is_focused = false
	is_in_motion = false
	Main = get_tree().get_root().get_node("Main")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_in_motion:
		if is_focused && position.y < focused_position.y:
			position += speed
		if is_focused && position.y >= focused_position.y:
			position = focused_position
			is_in_motion = false
			focused.emit()
		if !is_focused && position.y > unfocused_position.y:
			position -= speed
		if !is_focused && position.y <= unfocused_position.y:
			position = unfocused_position
			is_in_motion = false
			modulate.a = 1
			unfocused.emit()

func initiate_invader_actions():
	# Fade when leaving ravage space
	var old_ravage_card = $RavageSpace.detach()
	# Check if there is something in RavageSpace...
	if old_ravage_card != null:
		$InvaderCardTransformer.attach(old_ravage_card)
		$InvaderCardTransformer.init_move($RavageSpace.position+Vector2(5,5), Vector2($RavageSpace.position.x, $RavageSpace.position.y - 500), Vector2(0, -20))
		$InvaderCardTransformer.init_fade(1, 0)
		await $InvaderCardTransformer.transformed
		old_ravage_card = $InvaderCardTransformer.detach()
		old_ravage_card.queue_free()
		
	# From build space to ravage space
	var old_build_card = $BuildSpace.detach()
	# Check if there is something in BuildSpace...
	if old_build_card != null:
		$InvaderCardTransformer.attach(old_build_card)
		$InvaderCardTransformer.init_move($BuildSpace.position+Vector2(5,5), $RavageSpace.position+Vector2(5,5))
		await $InvaderCardTransformer.transformed
		old_build_card = $InvaderCardTransformer.detach()
		$RavageSpace.attach(old_build_card)
		await initiate_ravage(old_build_card.land_types)
	
	# From explore space to build space
	var old_explore_card = $ExploreSpace.detach()
	# Check if there is something in RavageSpace...
	if old_explore_card != null:
		$InvaderCardTransformer.attach(old_explore_card)
		$InvaderDeck.visible = true
		$InvaderCardTransformer.init_move($ExploreSpace.position+Vector2(5,5), $BuildSpace.position+Vector2(5,5))
		await $InvaderCardTransformer.transformed
		old_explore_card = $InvaderCardTransformer.detach( )
		print(old_explore_card)
		$BuildSpace.attach(old_explore_card)
		await initiate_build(old_explore_card.land_types)
	
	# From deck to explore space
	if !get_parent().invader_deck_empty:
		$InvaderDeck.visible = false
		var drawn_card = $InvaderDeck.draw()
		$ExploreSpace.attach(drawn_card)
		await initiate_explore(drawn_card.land_types)
	invader_actions_completed.emit()
	
# Explore the land type
func initiate_explore(land_types):
	explore_initiated.emit()
	await pre_invader_action_wait()
	var regions = Main.get_regions()
	# Iterate through all land types on the card
	for land_type in land_types:
		explore_initiated.emit(land_type)
		# Iterate through all regions..
		for region in regions:
			if region.blocked_invader_actions[0]:
				continue
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
	var regions = Main.get_regions()
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
					if !region.blocked_invader_actions[1][1]:
						await timed_invader_action(region, "add_city")
				# Else, add a town
				else:
					if !region.blocked_invader_actions[1][0]:
						await timed_invader_action(region, "add_town")
	built.emit()

# When the ravage space emits the "ravage" signal wtih the card's land_type
func initiate_ravage(land_types):
	ravage_initiated.emit()
	await pre_invader_action_wait()
	var regions = Main.get_regions()
	for land_type in land_types:
		ravage_initiated.emit(land_type)
		# Iterate through all regions
		for region in regions:
			if region.blocked_invader_actions[2]:
				continue
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
			
			if damage == 0:
				continue
				
			# Decrease according to defense
			var init_defense = region.defense
			region.reduce_defense(damage)
			damage -= init_defense
			if damage < 0:
				damage = 0
				
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
		if region.dahans.size() == 0:
			break
		await Main.destroy_dahan(region, region.dahans[0], true)
	# If any remain, see if the invaders damage 1
	# Prompt and allow player to choose 1 damage at a time 
	if region.dahans.size() > 0 && dahan_damaged:
		await Main.damage_dahan(region, region.dahans[0], true)

# Handles logic of destroying / damaging invaders
func dahan_fight_back(region):
	region.set_lit()
	var damage = region.dahans.size() * 2
	while damage > 0:
		dahan_fight_back_initiated.emit(damage)
		var selected = await Main.select_invaders_for_damage([region])
		if selected == null:
			dahan_fight_back_resolved.emit()
			region.set_unlit()
			return
		var invader = selected["token"]
		await Main.damage_invader(region, invader, false)
		damage -= 1
	region.set_unlit()
	dahan_fight_back_resolved.emit()

# Add blight to the region, cascading if one is already present
func invaders_damage_the_land(region):
	var had_blight = region.blights.size() > 0
	var had_presence = region.has_presence()
	await timed_invader_action(region, "add_blight")
	if had_presence:
		region.remove_presence()
	if had_blight:
		await blight_cascades(region)

func blight_cascades(region):
	var adjacent_regions = region.adjacent_regions
	blight_cascade_initiated.emit()

	# Defer to function which prompts region selection and returns the region
	var cascading_region = await prompt_region_cascade_selection(adjacent_regions)
	blight_cascade_resolved.emit()
	await invaders_damage_the_land(cascading_region)

func prompt_region_cascade_selection(regions):
	for region in regions:
		region.set_active(blight_scene.instantiate())
	var selected_region = await Main.player_selection_made
	for region in regions:
		region.set_inactive()
	return selected_region["region"]
	
func pre_invader_action_wait():
	$InvaderActionTimer.start()
	await $InvaderActionTimer.timeout

func timed_invader_action(region, method):
	region.set_lit()
	region.call(method)
	$InvaderActionTimer.start()
	await $InvaderActionTimer.timeout
	region.set_unlit()

func set_focused():
	var is_map_active = get_tree().get_root().get_node("Main").map_is_active
	if is_map_active:
		modulate.a = 0.5
	is_focused = true
	is_in_motion = true

func set_unfocused():
	is_focused = false
	is_in_motion = true

func update_transparency(is_map_active):
	if is_focused && is_map_active:
		modulate.a = 0.5
	else:
		modulate.a = 1

func _on_mouse_entered():
	$HighlightPolygon.visible = true

func _on_mouse_exited():
	$HighlightPolygon.visible = false

func _on_input_event(viewport, event, shape_idx):
	if is_in_motion:
		return
	if (event is InputEventMouseButton && !event.pressed):
		if !is_focused:
			set_focused()
		else:
			set_unfocused()
