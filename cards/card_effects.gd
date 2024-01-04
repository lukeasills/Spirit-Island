class_name card_effects

extends Node

@onready var LandMap = get_node("/root/Main/LandMap")
@onready var LabelContainer = get_node("/root/Main/LabelContainer")
@onready var effect_timer = get_node("/root/CardEffectTimer")
@onready var SkipButton = get_node("/root/Main/SkipButton")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func card_effects_on_ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func await_timer():
	effect_timer.start()
	await effect_timer.timeout

# - Select functions
# -- Select invaders

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
	if !skippable:
		selected = await LandMap.active_token_selected
	else:
		selected = await await_skippable_selection()
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
	if !skippable:
		selected = await LandMap.active_token_selected
	else:
		selected = await await_skippable_selection()
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
	if !skippable:
		selected = await LandMap.active_token_selected
	else:
		selected = await await_skippable_selection()
	for region in regions:
		region.set_unlit()
		region.deactivate_invaders()
	return selected

# -- Select dahans

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
	if !skippable:
		selected = await LandMap.active_token_selected
	else:
		selected = await await_skippable_selection()
	for region in regions:
		region.set_unlit()
		region.deactivate_dahan()
	return selected
# -- Select lands

func select_land(regions, skippable=false):
	var total_activated = 0
	for region in regions:
		total_activated += region.set_active()
	if regions.size() == 0:
		return null
	var selected
	if !skippable:
		selected = await LandMap.active_region_selected
	else:
		selected = await await_skippable_selection()
	for region in regions:
		region.set_inactive()
	return selected

# - Region condition functions

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
	var all_lands = LandMap.get_children().slice(0, LandMap.get_child_count()-1)
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

# - Effect functions

# -- Push functions
func push_token(token, source, destination, is_delayed):
	token.visible = false
	if source.dahans.has(token):
		token = source.remove_dahan(token, false)
		destination.add_dahan(token)
	if source.explorers.has(token):
		token = source.remove_explorer(token, false)
		destination.add_explorer(token)
	if source.towns.has(token):
		token = source.remove_town(token, false)
		destination.add_town(token)
	if source.cities.has(token):
		token = source.remove_city(token, false)
		destination.add_city(token)
	token.visible = true
	await await_timer()

# -- Gather functions (currently redundant with push)
func gather_token(token, source, destination, is_delayed):
	token.visible = false
	if source.dahans.has(token):
		token = source.remove_dahan(token, false)
		destination.add_dahan(token)
	if source.explorers.has(token):
		token = source.remove_explorer(token, false)
		destination.add_explorer(token)
	if source.towns.has(token):
		token = source.remove_town(token, false)
		destination.add_town(token)
	if source.cities.has(token):
		token = source.remove_city(token, false)
		destination.add_city(token)
	token.visible = true
	await await_timer()
	
# -- Remove functions
func remove_invader(region, selected, is_delayed):
	await LandMap.remove_invader(region, selected, is_delayed)

# -- Destroy functions
func destroy_invader(region, selected, is_delayed):
	await LandMap.destroy_invader(region, selected, is_delayed)

# -- Damage and defend functions
func damage_invader(region, selected, is_delayed):
	await LandMap.damage_invader(region, selected, is_delayed)

func defend(regions, type, how_much):
	for region in regions:
		region.set_lit()
		var how_much_this_one = how_much
		if type == "per_dahan":
			how_much_this_one *= region.dahans.size()
		region.add_defense(how_much_this_one)
		await await_timer()
		region.set_unlit()

# -- Block invader action functions
func block_invader_actions(regions, actions):
	for region in regions:
		region.set_lit()
		region.blocked_invader_actions[0] = region.blocked_invader_actions[0] || actions[0]
		region.blocked_invader_actions[1] = [region.blocked_invader_actions[1][0] || actions[1][0],region.blocked_invader_actions[1][1] || actions[1][1]]
		region.blocked_invader_actions[2] = region.blocked_invader_actions[2] || actions[2]
		await await_timer()
		region.set_unlit()
		

# - Skippable action functions
func await_skippable_selection():
	SkipButton.visible = true
	SkipButton.disabled = false
	var selected = await PlayerInputHandler.skippable_selection_made
	SkipButton.visible = false
	SkipButton.disabled = true
	return selected
