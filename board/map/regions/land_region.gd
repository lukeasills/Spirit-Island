extends Area2D

# Interactible variables
var active

# Exported variables
@export var id: int
@export var land_type: String: set = set_type
@export var is_coastal: bool
@export var adjacent_regions: Array[Node]

# Count variables
# TODO: smarter code might ensure that I don't have to manually set these to start
@export var blights: Array[Node]
@export var explorers: Array[Node]
@export var towns: Array[Node]
@export var cities: Array[Node]
@export var dahans: Array[Node]

var defense
var blocked_invader_actions


# Called when the node enters the scene tree for the first time.
func _ready():
	active = false
	defense = 0
	# Explore, Build [Towns, Cities], Ravage respectively
	blocked_invader_actions = [false, [false, false], false]

func set_color(new_color: Color):
	$RegionPolygon.color = new_color

func set_type(type: String):
	land_type = type

func set_id(id_number):
	id = id_number

# Token functions

# Adding tokens, optionally takes a token as parameter

func add_explorer(explorer = get_parent().explorer_scene.instantiate()):
	$TokenContainer.add_child(explorer)
	explorers.append(explorer)

func add_town(town = get_parent().town_scene.instantiate()):
	$TokenContainer.add_child(town)
	towns.append(town)

func add_city(city = get_parent().city_scene.instantiate()):
	$TokenContainer.add_child(city)
	cities.append(city)

func add_blight(blight = get_parent().blight_scene.instantiate()):
	$TokenContainer.add_child(blight)
	blights.append(blight)

func add_dahan(dahan = get_parent().dahan_scene.instantiate()):
	$TokenContainer.add_child(dahan)
	dahans.append(dahan)

# Functions for damaging tokens

func damage_dahan(dahan):
	dahan.set_damaged()

func damage_town(town):
	town.set_damaged()

func damage_city(city, damage):
	city.set_damaged(damage)

# Functions for destroying tokens

func destroy_dahan(dahan):
	$TokenContainer.remove_child(dahan)
	dahans.erase(dahan)
	dahan.queue_free()

func destroy_explorer(explorer):
	$TokenContainer.remove_child(explorer)
	explorers.erase(explorer)
	explorer.queue_free()

func destroy_town(town):
	$TokenContainer.remove_child(town)
	towns.erase(town)
	town.queue_free()

func destroy_city(city):
	$TokenContainer.remove_child(city)
	cities.erase(city)
	city.queue_free()

# Functions for removing tokens
# TODO: Currently highly redundant with destroy

func remove_dahan(dahan, delete=true):
	$TokenContainer.remove_child(dahan)
	dahans.erase(dahan)
	if delete:
		dahan.queue_free()
	else:
		return dahan

func remove_explorer(explorer, delete=true):
	$TokenContainer.remove_child(explorer)
	explorers.erase(explorer)
	if delete:
		explorer.queue_free()
	else:
		return explorer

func remove_town(town, delete=true):
	$TokenContainer.remove_child(town)
	towns.erase(town)
	if delete:
		town.queue_free()
	else:
		return town

func remove_city(city, delete=true):
	$TokenContainer.remove_child(city)
	cities.erase(city)
	if delete:
		city.queue_free()
	else:
		return city

func remove_blight(blight):
	$TokenContainer.remove_child(blight)
	blights.erase(blight)

func has_invaders():
	if explorers.size() + towns.size() + cities.size() > 0:
		return true
	else:
		return false

# Defense functions
func add_defense(how_much):
	defense += how_much
	$DefenseIcon.set_amount(defense)

func reduce_defense(how_much):
	defense -= how_much
	if defense < 0:
		defense = 0
	$DefenseIcon.set_amount(defense)

func reset_defense():
	defense = 0
	$DefenseIcon.set_amount(defense)

func reset_blocked_invader_actions():
	blocked_invader_actions = [false, [false, false], false]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Setting invaders selectable for player distributing damage
func activate_invaders_for_damage(if_explorers=true, if_towns=true, if_cities=true):
	var total_activated = 0
	if if_explorers:
		for explorer in explorers:
			explorer.set_active_for_damage()
			total_activated += 1
	if if_towns:
		for town in towns:
			town.set_active_for_damage()
			total_activated += 1
	if if_cities:
		for city in cities:
			city.set_active_for_damage()
			total_activated += 1
	return total_activated

func activate_invaders_for_destruction(if_explorers=true, if_towns=true, if_cities=true):
	var total_activated = 0
	if if_explorers:
		for explorer in explorers:
			explorer.set_active_for_destruction()
			total_activated += 1
	if if_towns:
		for town in towns:
			town.set_active_for_destruction()
			total_activated += 1
	if if_cities:
		for city in cities:
			city.set_active_for_destruction()
			total_activated += 1
	return total_activated

func activate_invaders_for_removal(if_explorers=true, if_towns=true, if_cities=true):
	var total_activated = 0
	if if_explorers:
		for explorer in explorers:
			explorer.set_active_for_removal()
			total_activated += 1
	if if_towns:
		for town in towns:
			town.set_active_for_removal()
			total_activated += 1
	if if_cities:
		for city in cities:
			city.set_active_for_removal()
			total_activated += 1
	return total_activated

# Setting dahan active for removal
func activate_dahan_for_removal():
	var total_activated = 0
	for dahan in dahans:
		dahan.set_active_for_removal()
		total_activated += 1
	return total_activated

# Setting invaders inactive again
func deactivate_invaders():
	for explorer in explorers:
		explorer.set_inactive()
	for town in towns:
		town.set_inactive()
	for city in cities:
		city.set_inactive()

func deactivate_dahan():
	for dahan in dahans:
		dahan.set_inactive()

func token_selected(token):
	get_parent().token_clicked(token, self)

func set_active():
	active = true
	return 1

func set_inactive():
	active = false
	$HighlightPolygon.color.a = 0.1

func set_lit():
	$HighlightPolygon.color.a = 0.25

func set_unlit():
	$HighlightPolygon.color.a = 0.1

func _on_mouse_entered():
	if active:
		$HighlightPolygon.color.a = 0.4
		get_parent().region_entered(self)

func _on_mouse_exited():
	if active:
		$HighlightPolygon.color.a = 0.1
		get_parent().region_exited(self)

func _on_input_event(viewport, event, shape_idx):
	if !active:
		return
	if (event is InputEventMouseButton && !event.pressed):
		get_parent().region_clicked(self)
		active = false
