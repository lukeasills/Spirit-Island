extends Node

var invader_deck_empty = false

var turn_in_progress
var map_is_active
var is_awaiting_skippable_selection
var gather_in_progress
var gather_destination


@onready var placeholder_scene = preload("res://tokens/map_tokens/place_holder_token.tscn")
@onready var blight_scene = preload("res://tokens/map_tokens/blight.tscn")
@onready var explorer_scene = preload("res://tokens/map_tokens/invaders/explorer.tscn")
@onready var town_scene = preload("res://tokens/map_tokens/invaders/town.tscn")
@onready var city_scene = preload("res://tokens/map_tokens/invaders/city.tscn")
@onready var dahan_scene = preload("res://tokens/map_tokens/dahan.tscn")

@onready var effect_timer = get_node("/root/CardEffectTimer")

signal active_region_hovered
signal active_region_end_hovered
signal active_token_hovered
signal active_token_end_hovered

signal player_selection_made

# Called when the node enters the scene tree for the first time.
func _ready():
	turn_in_progress = false
	map_is_active = false
	gather_in_progress = false
	gather_destination = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_SPACE:
			if !turn_in_progress:
				await initiate_main_turn_loop()

func initiate_main_turn_loop():
	turn_in_progress = true
	await $FearBoard.resolve_earned_fear_cards(true)
	map_is_active = true
	$InvaderBoard.update_transparency(map_is_active)
	await $InvaderBoard.initiate_invader_actions()
	map_is_active = false
	$InvaderBoard.update_transparency(map_is_active)
	await time_passes()

func time_passes():
	get_tree().call_group("dahan", "reset_damage")
	get_tree().call_group("towns", "reset_damage")
	get_tree().call_group("cities", "reset_damage")
	get_tree().call_group("regions", "reset_defense")
	get_tree().call_group("regions", "reset_blocked_invader_actions")

func get_token_instance(type):
	var new_token
	if type == "placeholder":
		new_token = placeholder_scene.instantiate()
	elif type == "blight":
		new_token = blight_scene.instantiate()
	elif type == "explorer":
		new_token = explorer_scene.instantiate()
	elif type == "town":
		new_token = town_scene.instantiate()
	elif type == "city":
		new_token = city_scene.instantiate()
	elif type == "dahan":
		new_token = dahan_scene.instantiate()
	return new_token

# - FEAR BOARD RELATIONSHIPS
func generate_fear(num):
	await $FearBoard.generate_fear(num)

func resolve_fear_card(fear_card, fear_level):
	await set_fear_card_active(fear_card, fear_level)
	await prompt_continue_button()
	fear_card.mouse_filter = 0
	await fear_card.resolve_effects(fear_level)
	return await set_fear_card_inactive()
	
func set_fear_card_active(fear_card, fear_level):
	$ActiveCardTransformer.attach(fear_card)
	$ActiveCardTransformer.init_move($FearBoard.position + $FearBoard/EarnedFearCardsSpot.position, $ActiveCardSpace.position)
	$ActiveCardTransformer.init_scale($FearBoard/EarnedFearCardsSpot.scale, Vector2(2.2,2.2))
	await $ActiveCardTransformer.transformed
	fear_card = $ActiveCardTransformer.detach()
	await $ActiveCardSpace.attach_fear_card(fear_card, fear_level)

func set_fear_card_inactive():
	var fear_card = await $ActiveCardSpace.detach_fear_card()
	$ActiveCardTransformer.attach(fear_card)
	$ActiveCardTransformer.init_move($ActiveCardSpace.position, Vector2($ActiveCardSpace.position.x, $ActiveCardSpace.position.y - 500), Vector2(0, -20))
	$ActiveCardTransformer.init_fade(1, 0)
	await $ActiveCardTransformer.transformed
	fear_card = $ActiveCardTransformer.detach()
	return fear_card

func prompt_continue_button():
	$ActiveCardSpace.enable_skip_button()
	await $ActiveCardSpace.continue_pressed
	$ActiveCardSpace.disable_skip_button()

# - LAND MAP RELATIONSHIPS

func await_timer():
	effect_timer.start()
	await effect_timer.timeout

# -- Select functions
# Make components selectable in certain regions and return the player's choice
# --- Select invaders

func select_invaders_for_damage(regions, explorers=true, towns=true, cities=true, skippable=false):
	var total_activated = 0
	for region in regions:
		region.set_lit()
		total_activated += region.activate_invaders_for_damage(explorers, towns, cities)
	if total_activated == 0:
		for region in regions:
			region.set_unlit()
		return null
	var selected
	if skippable:
		$ActiveCardSpace.enable_skip_button()
	selected = await player_selection_made
	if skippable:
		$ActiveCardSpace.disable_skip_button()
	for region in regions:
		region.deactivate_invaders()
		region.set_unlit()
	return selected

func select_invaders_for_destruction(regions, explorers=true, towns=true, cities=true, skippable=false):
	var total_activated = 0
	for region in regions:
		region.set_lit()
		total_activated += region.activate_invaders_for_destruction(explorers, towns, cities)
	if total_activated == 0:
		for region in regions:
			region.set_unlit()
		return null
	var selected
	if skippable:
		$ActiveCardSpace.enable_skip_button()
	selected = await player_selection_made
	if skippable:
		$ActiveCardSpace.disable_skip_button()
	for region in regions:
		region.set_unlit()
		region.deactivate_invaders()
	return selected

func select_invaders_for_removal(regions, explorers=true, towns=true, cities=true, skippable=false):
	var total_activated = 0
	for region in regions:
		region.set_lit()
		total_activated += region.activate_invaders_for_removal(explorers, towns, cities)
	if total_activated == 0:
		for region in regions:
			region.set_unlit()
		return null
	var selected
	if skippable:
		$ActiveCardSpace.enable_skip_button()
	selected = await player_selection_made
	if skippable:
		$ActiveCardSpace.disable_skip_button()
	for region in regions:
		region.set_unlit()
		region.deactivate_invaders()
	return selected

# --- Select dahans

func select_dahan_for_removal(regions, skippable=false):
	var total_activated = 0
	for region in regions:
		region.set_lit()
		total_activated += region.activate_dahan_for_removal()
	if total_activated == 0:
		for region in regions:
			region.set_unlit()
		return null
	var selected
	if skippable:
		$ActiveCardSpace.enable_skip_button()
	selected = await player_selection_made
	if skippable:
		$ActiveCardSpace.disable_skip_button()
	for region in regions:
		region.set_unlit()
		region.deactivate_dahan()
	return selected

# --- Select lands

func select_land(regions, skippable=false, hover_token = null):
	var total_activated = 0
	if hover_token != null:
		hover_token = get_token_instance(hover_token)
	for region in regions:
		total_activated += region.set_active(hover_token)
	if regions.size() == 0:
		return null
	var selected
	if skippable:
		$ActiveCardSpace.enable_skip_button()
	selected = await player_selection_made
	if skippable:
		$ActiveCardSpace.disable_skip_button()
	for region in regions:
		region.set_inactive()
	return selected
	

# -- Region condition functions
# Returns an array of regions based on a condition

func get_regions():
	return $LandMap.get_regions()
	
func get_coastal_land():
	var all_lands = get_any_land()
	var coastal_lands = []
	for land in all_lands:
		if land.is_coastal:
			coastal_lands.append(land)
	return coastal_lands

func get_inland_land():
	var all_lands = get_any_land()
	var inland_lands = []
	for land in all_lands:
		if !land.is_coastal:
			inland_lands.append(land)
	return inland_lands

func get_any_land():
	var all_lands = $LandMap.get_regions()
	return all_lands

func get_land_with_invaders(type="at least", how_many=1):
	var all_lands = get_any_land()
	var land_with_invaders = []
	for land in all_lands:
		var count = land.explorers.size() + land.towns.size() + land.cities.size()
		if type == "exactly" && count == how_many:
			land_with_invaders.append(land)
		if type == "at least" && count >= how_many:
			land_with_invaders.append(land)
		if type == "or fewer" && count <= how_many:
			land_with_invaders.append(land)
	return land_with_invaders

func get_land_with_cities():
	var lands_with_invaders = get_land_with_invaders()
	var lands_with_cities = []
	for land in lands_with_invaders:
		if land.cities.size() > 0:
			lands_with_cities.append(land)
	return lands_with_cities

func get_land_with_dahan(type="at least", how_many=1):
	var all_lands = get_any_land()
	var land_with_dahan = []
	for land in all_lands:
		var count = land.dahans.size()
		if type == "exactly" && count == how_many:
			land_with_dahan.append(land)
		if type == "at least" && count >= how_many:
			land_with_dahan.append(land)
		if type == "or fewer" && count <= how_many:
			land_with_dahan.append(land)
	return land_with_dahan

func get_land_with_presence(holy_site = false):
	var all_lands = get_any_land()
	var land_with_presence = []
	for land in all_lands:
		if holy_site:
			if land.has_holy_site():
				land_with_presence.append(land)
		elif land.has_presence():
			land_with_presence.append(land)
	return land_with_presence

# -- Effect functions

# --- Push functions
func push_token(token, source, destination, is_delayed):
	if source.dahans.has(token):
		token = await $LandMap.push_dahan(source, token, destination, is_delayed)
	else:
		token = await $LandMap.push_invader(source, token, destination, is_delayed)
	await await_timer()

# --- Gather functions
func initiate_gather(dest_region):
	gather_destination = dest_region
	gather_destination.set_lit()
	gather_in_progress = true

func resolve_gather():
	gather_destination.set_unlit()
	gather_destination.set_lit()
	gather_in_progress = false
	gather_destination = null

# Currently redundant with push
func gather_token(token, source, destination, is_delayed):
	if source.dahans.has(token):
		token = await $LandMap.push_dahan(source, token, destination, is_delayed)
	else:
		token = await $LandMap.push_invader(source, token, destination, is_delayed)
	await await_timer()
	
# --- Remove functions
func remove_invader(region, selected, is_delayed):
	await $LandMap.remove_invader(region, selected, is_delayed)

# --- Destroy functions
func destroy_invader(region, selected, is_delayed):
	await $LandMap.destroy_invader(region, selected, is_delayed)

func destroy_dahan(region, dahan, is_delayed):
	await $LandMap.destroy_dahan(region, dahan, is_delayed)

# --- Damage and defend functions
func damage_invader(region, selected, is_delayed):
	await $LandMap.damage_invader(region, selected, is_delayed)

func damage_dahan(region, dahan, is_delayed):
	await $LandMap.damage_dahan(region, dahan, is_delayed)

func defend(regions, type, how_much):
	for region in regions:
		region.set_lit()
		var how_much_this_one = how_much
		if type == "per_dahan":
			how_much_this_one *= region.dahans.size()
		region.add_defense(how_much_this_one)
		await await_timer()
		region.set_unlit()

# --- Block invader action functions
func block_invader_actions(regions, actions):
	for region in regions:
		region.set_lit()
		region.blocked_invader_actions[0] = region.blocked_invader_actions[0] || actions[0]
		region.blocked_invader_actions[1] = [region.blocked_invader_actions[1][0] || actions[1][0],region.blocked_invader_actions[1][1] || actions[1][1]]
		region.blocked_invader_actions[2] = region.blocked_invader_actions[2] || actions[2]
		await await_timer()
		region.set_unlit()

# -- TOKEN INTERACTION FUNCTIONS

func on_token_selected(token):
	if token.active:
		player_selection_made.emit({"token":token,"skipped":false, "option_selected":false})

func on_token_hovered(token):
	if token.active:
		if gather_in_progress:
			var source_region = token.get_parent().get_parent()
			var type = "dahan"
			if source_region.explorers.has(token):
				type = "explorer"
			elif source_region.towns.has(token):
				type = "town"
			elif source_region.cities.has(token):
				type = "city"
			gather_destination.set_lit(get_token_instance(type))
		active_token_hovered.emit(token)

func on_token_end_hovered(token):
	if token.active:
		if gather_in_progress:
			gather_destination.set_unlit()
			gather_destination.set_lit()
		active_token_end_hovered.emit(token)

# -- REGION INTERACTION FUNCTIONS

func on_region_selected(region):
	if region.active:
		player_selection_made.emit({"region":region,"skipped":false, "option_selected":false})

func on_region_hovered(region):
	if region.active:
		active_region_hovered.emit(region)

func on_region_end_hovered(region):
	if region.active:
		active_region_end_hovered.emit(region)

# -- ACTIVE CARD INTERACTION FUNCTIONS
func _on_active_card_space_continue_pressed():
	player_selection_made.emit({"skipped":true})

func on_option_button_pressed(option_number):
	print(str("option selected: ", option_number))
	player_selection_made.emit({"skipped":false,"option_selected":true,"option":option_number})

func _on_invader_deck_emptied():
	invader_deck_empty = true

func _on_invader_board_invader_actions_completed():
	turn_in_progress = false
