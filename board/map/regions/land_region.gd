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


# Called when the node enters the scene tree for the first time.
func _ready():
	active = false

func set_color(new_color: Color):
	$RegionPolygon.color = new_color

func set_type(type: String):
	land_type = type

func set_id(id_number):
	id = id_number

# Token functions

# Adding tokens

func add_explorer():
	var explorer = get_parent().explorer_scene.instantiate()
	$TokenContainer.add_child(explorer)
	explorers.append(explorer)

func add_town():
	var town = get_parent().town_scene.instantiate()
	$TokenContainer.add_child(town)
	towns.append(town)

func add_city():
	var city = get_parent().city_scene.instantiate()
	$TokenContainer.add_child(city)
	cities.append(city)

func add_blight():
	var blight = get_parent().blight_scene.instantiate()
	$TokenContainer.add_child(blight)
	blights.append(blight)

func add_dahan():
	var dahan = get_parent().dahan_scene.instantiate()
	$TokenContainer.add_child(dahan)
	dahans.append(dahan)

# Destroy and damage tokens

func destroy_dahan():
	var dahan = dahans.pop_front()
	$TokenContainer.remove_child(dahan)
	dahan.queue_free()

func damage_dahan():
	var dahan = dahans[0]
	dahan.set_damaged()

func damage_town(town):
	town.set_damaged()

func damage_city(city, damage):
	city.set_damaged(damage)

func destroy_explorer(explorer):
	explorers.erase(explorer)
	explorer.queue_free()

func destroy_town(town):
	towns.erase(town)
	town.queue_free()

func destroy_city(city):
	cities.erase(city)
	city.queue_free()

func has_invaders():
	if explorers.size() + towns.size() + cities.size() > 0:
		return true
	else:
		return false

func test_has_invaders():
	print("why not? size of tokencontainer: ", $TokenContainer.get_child_count())
	print("explorers: ", explorers.size())
	print("towns: ", towns.size())
	print("cities: ", cities.size())
	if explorers.size() + towns.size() + cities.size() > 0:
		return true
	else:
		return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Setting invaders selectable for player distributing damage
func set_invaders_active_for_damage():
	for explorer in explorers:
		explorer.set_active_for_damage()
	for town in towns:
		town.set_active_for_damage()
	for city in cities:
		city.set_active_for_damage()

func damage_invader(invader):
	if explorers.has(invader):
		destroy_explorer(invader)
	elif towns.has(invader):
		if invader.damaged:
			destroy_town(invader)
		else:
			damage_town(invader)
	else:
		if invader.damage == 2:
			destroy_city(invader)
		else:
			damage_city(invader, invader.damage + 1)

# Setting invaders inactive again
func set_invaders_inactive():
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
