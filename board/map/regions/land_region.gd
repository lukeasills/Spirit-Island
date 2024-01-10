extends Area2D

# Interactible variables
var active
var highlight_token
signal selected
signal hovered
signal end_hovered

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
	selected.connect(get_tree().get_root().get_node("Main").on_region_selected.bind(self))
	hovered.connect(get_tree().get_root().get_node("Main").on_region_hovered.bind(self))
	end_hovered.connect(get_tree().get_root().get_node("Main").on_region_end_hovered.bind(self))
	
	# Explore, Build [Towns, Cities], Ravage respectively
	blocked_invader_actions = [false, [false, false], false]

func set_color(new_color: Color):
	$RegionPolygon.color = new_color

func set_type(type: String):
	land_type = type

func set_id(id_number):
	id = id_number

# Token functions

func get_token_position(token):
	return token.position + $TokenContainer.position

func get_next_token_position():
	return $TokenContainer.get_next_position() + $TokenContainer.position

# Adding tokens, optionally takes a token as parameter

func add_placeholder(placeholder):
	$TokenContainer.add_child(placeholder)

func remove_placeholder(placeholder):
	$TokenContainer.remove_child(placeholder)

func add_explorer(explorer = get_tree().get_root().get_node("Main").get_token_instance("explorer")):
	$TokenContainer.add_child(explorer)
	explorers.append(explorer)

func add_town(town = get_tree().get_root().get_node("Main").get_token_instance("town")):
	$TokenContainer.add_child(town)
	towns.append(town)

func add_city(city = get_tree().get_root().get_node("Main").get_token_instance("city")):
	$TokenContainer.add_child(city)
	cities.append(city)

func add_blight(blight = get_tree().get_root().get_node("Main").get_token_instance("blight")):
	$TokenContainer.add_child(blight)
	blights.append(blight)

func add_dahan(dahan = get_tree().get_root().get_node("Main").get_token_instance("dahan")):
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
	dahan.init_fade()
	await dahan.faded 
	$TokenContainer.remove_child(dahan)
	dahans.erase(dahan)
	dahan.queue_free()

func destroy_explorer(explorer):
	explorer.init_fade()
	await explorer.faded 
	$TokenContainer.remove_child(explorer)
	explorers.erase(explorer)
	explorer.queue_free()

func destroy_town(town):
	town.init_fade()
	await town.faded 
	$TokenContainer.remove_child(town)
	towns.erase(town)
	town.queue_free()

func destroy_city(city):
	city.init_fade()
	await city.faded 
	$TokenContainer.remove_child(city)	
	cities.erase(city)
	city.queue_free()

# Functions for removing tokens
# TODO: Currently highly redundant with destroy

func remove_dahan(dahan, delete=true):
	if delete:
		dahan.init_fade()
		await dahan.faded 
		$TokenContainer.remove_child(dahan)	
		dahans.erase(dahan)
		dahan.queue_free()
	else:
		$TokenContainer.remove_child(dahan)	
		dahans.erase(dahan)
		return dahan

func remove_explorer(explorer, delete=true):
	if delete:
		explorer.init_fade()
		await explorer.faded 
		$TokenContainer.remove_child(explorer)
		explorers.erase(explorer)
		explorer.queue_free()
	else:
		$TokenContainer.remove_child(explorer)
		explorers.erase(explorer)
		return explorer

func remove_town(town, delete=true):
	if delete:
		town.init_fade()
		await town.faded 
		$TokenContainer.remove_child(town)
		towns.erase(town)
		town.queue_free()
	else:
		$TokenContainer.remove_child(town)
		towns.erase(town)
		return town

func remove_city(city, delete=true):
	if delete:
		city.init_fade()
		await city.faded 
		$TokenContainer.remove_child(city)
		cities.erase(city)
		city.queue_free()
	else:
		$TokenContainer.remove_child(city)
		cities.erase(city)
		return city

func remove_blight(blight):
	blight.init_fade()
	await blight.faded 
	$TokenContainer.remove_child(blight)
	blights.erase(blight)

func has_invaders():
	if explorers.size() + towns.size() + cities.size() > 0:
		return true
	else:
		return false

# Presence functions
func get_presence():
	return $Presence

func has_presence():
	return $Presence.is_present

func has_holy_site():
	return $Presence.is_holy_site
	
func add_presence(how_much = 1):
	$Presence.add_presence(how_much)

func remove_presence(how_much = 1):
	$Presence.remove_presence(how_much)

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

func set_active(token = null):
	highlight_token = token	
	if highlight_token != null:
		highlight_token.modulate.a = 0.6
		highlight_token.mouse_filter = 2
	active = true
	return 1

func set_inactive():
	active = false
	$HighlightPolygon.color.a = 0.1
	if highlight_token != null:
		if $TokenContainer.get_children().has(highlight_token):
			$TokenContainer.remove_child(highlight_token)
		highlight_token.queue_free()
		highlight_token = null

func set_lit(token = null):
	highlight_token = token	
	if highlight_token != null:
		highlight_token.modulate.a = 0.6
		highlight_token.mouse_filter = 2
		$TokenContainer.add_child(highlight_token)
	$HighlightPolygon.color.a = 0.25

func set_unlit():
	if highlight_token != null:
		if $TokenContainer.get_children().has(highlight_token):
			$TokenContainer.remove_child(highlight_token)
		highlight_token.queue_free()
		highlight_token = null
	$HighlightPolygon.color.a = 0.1

func _on_mouse_entered():
	if active:
		$HighlightPolygon.color.a = 0.4
		if highlight_token != null:
			$TokenContainer.add_child(highlight_token)
			print(highlight_token.mouse_filter)
		hovered.emit()

func _on_mouse_exited():
	if active:
		$HighlightPolygon.color.a = 0.1
		if highlight_token != null:
			$TokenContainer.remove_child(highlight_token)
		end_hovered.emit()

func _on_input_event(viewport, event, shape_idx):
	if !active:
		return
	if (event is InputEventMouseButton && !event.pressed):
		if highlight_token != null:
			$TokenContainer.remove_child(highlight_token)
			highlight_token.queue_free()
			highlight_token = null
		selected.emit()
		active = false
