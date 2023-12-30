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


# Called when the node enters the scene tree for the first time.
func _ready():
	active = false
	defense = 0

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

func remove_dahan(dahan):
	$TokenContainer.remove_child(dahan)
	dahans.erase(dahan)
	dahan.queue_free()

func remove_explorer(explorer):
	$TokenContainer.remove_child(explorer)
	explorers.erase(explorer)
	explorer.queue_free()

func remove_town(town):
	$TokenContainer.remove_child(town)
	towns.erase(town)
	town.queue_free()

func remove_city(city):
	$TokenContainer.remove_child(city)
	cities.erase(city)
	city.queue_free()

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Setting invaders selectable for player distributing damage
func activate_invaders_for_damage():
	for explorer in explorers:
		explorer.set_active_for_damage()
	for town in towns:
		town.set_active_for_damage()
	for city in cities:
		city.set_active_for_damage()

func activate_invaders_for_destruction():
	pass

# Setting invaders inactive again
func deactivate_invaders():
	for explorer in explorers:
		explorer.set_inactive()
	for town in towns:
		town.set_inactive()
	for city in cities:
		city.set_inactive()

func token_selected(token):
	get_parent().token_clicked(token)

func set_active():
	active = true

func set_inactive():
	active = false

func set_lit():
	$HighlightPolygon.color.a = 0.4

func set_unlit():
	$HighlightPolygon.color.a = 0.1

func _on_mouse_entered():
	if active:
		$RegionPolygon.color.a = 1
		get_parent().region_entered(self)

func _on_mouse_exited():
	if active:
		$RegionPolygon.color.a = 0.8
		get_parent().region_exited(self)

func _on_input_event(viewport, event, shape_idx):
	if !active:
		return
	if (event is InputEventMouseButton && !event.pressed):
		get_parent().region_clicked(self)
		active = false
