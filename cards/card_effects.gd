class_name card_effects

extends Node

@onready var LandMap = get_node("/root/Main/LandMap")
@onready var LabelContainer = get_node("/root/Main/LabelContainer")
@onready var effect_timer = get_node("/root/CardEffectTimer")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func await_timer():
	effect_timer.start()
	await effect_timer.timeout

# - Select functions
# -- Select tokens

func select_invaders_for_damage(regions, explorers=true, towns=true, cities=true):
	var total_activated = 0
	for region in regions:
		region.set_lit()
		total_activated += region.activate_invaders_for_damage(explorers, towns, cities)
	if total_activated == 0:
		for region in regions:
			region.set_unlit()
		return null
	var selected = await LandMap.active_token_selected
	for region in regions:
		region.deactivate_invaders()
		region.set_unlit()
	return selected

func select_invaders_for_destruction(regions, explorers=true, towns=true, cities=true):
	var total_activated = 0
	for region in regions:
		region.set_lit()
		total_activated += region.activate_invaders_for_destruction(explorers, towns, cities)
	if total_activated == 0:
		for region in regions:
			region.set_unlit()
		return null
	var selected = await LandMap.active_token_selected
	for region in regions:
		region.set_unlit()
		region.deactivate_invaders()
	return selected

func select_invaders_for_removal(regions, explorers=true, towns=true, cities=true):
	var total_activated = 0
	for region in regions:
		region.set_lit()
		total_activated += region.activate_invaders_for_removal(explorers, towns, cities)
	if total_activated == 0:
		for region in regions:
			region.set_unlit()
		return null
	var selected = await LandMap.active_token_selected
	for region in regions:
		region.set_unlit()
		region.deactivate_invaders()
	return selected

# -- Select lands

func select_land(regions):
	var total_activated = 0
	for region in regions:
		total_activated += region.set_active()
	if regions.size() == 0:
		return null
	var selected_region = await LandMap.active_region_selected
	for region in regions:
		region.set_inactive()
	return selected_region

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

# - Effect functions

# -- Push functions
func push_invader(selected, parameters):
	pass

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
		await await_timer()
		var how_much_this_one = how_much
		if type == "per_dahan":
			how_much_this_one *= region.dahans.size()
		region.add_defense(how_much_this_one)
		region.set_unlit()
