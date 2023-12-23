extends Area2D

@export var invader_scene: PackedScene
@export var blight_scene: PackedScene

# Interactible variables
var active

# Exported variables
@export var id: int
@export var land_type: String: set = set_type
@export var is_coastal: bool
@export var adjacent_regions: Array[Node]
# Count variables
var blight_count
var explorer_count
var town_count
var city_count


# Called when the node enters the scene tree for the first time.
func _ready():
	active = false
	blight_count = 0
	explorer_count = 0
	town_count = 0
	city_count = 0

func set_color(new_color: Color):
	$Polygon2D.color = new_color

func set_type(type: String):
	land_type = type

func set_id(id_number):
	id = id_number

func add_explorer():
	var invader = invader_scene.instantiate()
	invader.set_invader_type("explorer")
	$TokenContainer.add_child(invader)
	explorer_count += 1

func add_town():
	var invader = invader_scene.instantiate()
	invader.set_invader_type("town")
	$TokenContainer.add_child(invader)
	town_count += 1

func add_city():
	var invader = invader_scene.instantiate()
	invader.set_invader_type("city")
	$TokenContainer.add_child(invader)
	city_count += 1

func add_blight():
	var blight = blight_scene.instantiate()
	$TokenContainer.add_child(blight)
	blight_count += 1

func has_invaders():
	if explorer_count + town_count + city_count > 0:
		return true
	else:
		return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_active():
	active = true
	print("active")

func set_inactive():
	active = false

func set_lit():
	$Polygon2D.color.a = 1

func set_unlit():
	$Polygon2D.color.a = 0.8

func _on_mouse_entered():
	if active:
		$Polygon2D.color.a = 1
		get_parent().region_entered(self)

func _on_mouse_exited():
	if active:
		$Polygon2D.color.a = 0.8
		get_parent().region_exited(self)

func _on_input_event(viewport, event, shape_idx):
	if !active:
		return
	if (event is InputEventMouseButton && !event.pressed):
		get_parent().region_selected(self)
		active = false
