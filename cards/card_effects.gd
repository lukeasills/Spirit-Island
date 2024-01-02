class_name card_effects

extends Node

@onready var LandMap = get_node("/root/Main/LandMap")
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

# -- Functions for prompting selection of tokens
func select_invaders(regions):
	pass

func select_explorers(regions):
	pass

func select_towns(regions):
	pass

func select_cities(regions):
	pass

# -- Select lands


# - Region condition functions

func get_inland_land(parameters):
	pass

func get_any_land():
	var all_lands = LandMap.get_children().slice(0, LandMap.get_child_count()-1)
	return all_lands

func get_land_with_x_invaders(parameters):
	pass

func get_land_with_dahan():
	var all_lands = get_any_land()
	var land_with_dahan = []
	for land in all_lands:
		if land.dahans.size() > 0:
			land_with_dahan.append(land)
	return land_with_dahan

# - Effect functions

# -- Push functions
func push_invader(selected, parameters):
	pass

# -- Remove functions
func remove_invader(selected, parameters):
	pass

# -- Damage and defend functions
func distribute_damage(selected, parameters):
	pass

func defend(regions, type, how_much):
	for region in regions:
		await await_timer()
		var how_much_this_one = how_much
		if type == "per_dahan":
			how_much_this_one *= region.dahans.size()
		region.add_defense(how_much_this_one)
		print(region.defense)
