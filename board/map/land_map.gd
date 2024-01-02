extends MarginContainer
# Player input signals
signal active_region_entered
signal active_region_selected
signal active_region_exited
signal active_token_selected

@export var explorer_scene: PackedScene
@export var town_scene: PackedScene
@export var city_scene: PackedScene
@export var blight_scene: PackedScene
@export var dahan_scene: PackedScene

# For passing control to FearBoard
@export var fear_board: Node

var map_data = [
	{"type":"Jungle", "iscoastal":false, "adjacentregions": [1,3,4],
	"points": [Vector2(0,0), Vector2(330,165), Vector2(500,0), Vector2(665,250),
	Vector2(500,500), Vector2(330,330), Vector2(165,330), Vector2(0,0)],
	"center": Vector2(365, 240)},
	{"type":"Wetland", "iscoastal":false, "adjacentregions": [0,2,4,5],
	"points": [Vector2(500,0), Vector2(900,0), Vector2(1100,50), Vector2(1200,125),
	Vector2(1075,175), Vector2(1025,250), Vector2(665,250), Vector2(500,0)],
	"center": Vector2(825, 115)},
	{"type":"Sand", "iscoastal":true, "adjacentregions": [1,5],
	"points": [Vector2(900,0), Vector2(1300,0), Vector2(1600,100),Vector2(1350,250),
	Vector2(1250,350), Vector2(1200,125), Vector2(1100,50),Vector2(900,0)],
	"center": Vector2(1325, 120)},
	{"type":"Mountain", "iscoastal":false, "adjacentregions": [0,4,6],
	"points": [Vector2(165,330), Vector2(330,330), Vector2(500,500), Vector2(830,665),
	Vector2(250,830), Vector2(165,700),Vector2(225,500),Vector2(165,330)],
	"center": Vector2(385, 610)},
	{"type":"Sand", "iscoastal":false, "adjacentregions": [0,1,3,4,5],
	"points": [Vector2(665,250), Vector2(1025,250), Vector2(1000,350), Vector2(925,425),
	Vector2(900,550), Vector2(830,665), Vector2(500,500), Vector2(665,250)],
	"center": Vector2(755, 425)},
	{"type":"Wetland", "iscoastal":true, "adjacentregions": [1,2,4,6,7],
	"points": [Vector2(1025,250), Vector2(1075,175), Vector2(1200,125), Vector2(1250,350),
	Vector2(1200,550),Vector2(1135,600), Vector2(1050,575), Vector2(925,675),
	Vector2(900,550), Vector2(925,425), Vector2(1000,350), Vector2(1025,250)],
	"center": Vector2(1085, 415)},
	{"type":"Jungle", "iscoastal":false, "adjacentregions": [3,4,5,7],
	"points": [Vector2(250,830), Vector2(830,665), Vector2(900,550), Vector2(925,675),
	Vector2(875,830), Vector2(1100,900), Vector2(875,1000), Vector2(550,875),
	Vector2(250,830)],
	"center": Vector2(725, 810)},
	{"type":"Mountain", "iscoastal":true, "adjacentregions": [5,6],
	"points": [Vector2(925,675), Vector2(1050,575), Vector2(1135,600), Vector2(1200,550),
	Vector2(1250,650), Vector2(1175,775), Vector2(1100,900), Vector2(875,830),
	Vector2(925,675)],
	"center": Vector2(1060, 725)},
]

var color_dict = {
	"Jungle": Color(0.15, 0.56, 0.24, 0.8),
	"Water": Color(0.57, 0.91, 0.91, 0.8),
	"Sands": Color(0.92, 0.77, 0.32, 0.8),
	"Mountain": Color(0.47, 0.46, 0.49, 0.8)
}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Generalized functions for damaging tokens, removing if maxed-out
func damage_invader(region, token, is_delayed):
	# If explorer, 1 damage destroys it
	if region.explorers.has(token):
		await destroy_invader(region, token, is_delayed)
	# If a town, 2 options: destroy if damaged already, else damage
	elif region.towns.has(token):
		if token.damaged:
			await destroy_invader(region, token, is_delayed)
		else:
			region.damage_town(token)
			if is_delayed:
				$Timer.start()
				await $Timer.timeout
	# If a city, destroy if at 2 damage, else add damage
	else:
		if token.damage == 2:
			await destroy_invader(region, token, is_delayed)
		else:
			region.damage_city(token, token.damage + 1)
			if is_delayed:
				$Timer.start()
				await $Timer.timeout

func damage_dahan(region, token, is_delayed):
	# If already damaged, destroy it
	if token.damaged:
		await destroy_dahan(region, token, is_delayed)
	else:
		region.damage_dahan(token)
		if is_delayed:
			$Timer.start()
			await $Timer.timeout

# Generalized functions for destroying tokens
func destroy_invader(region, token, is_delayed):
	# Set the texture to reflect destruction
	token.set_destroyed()
	# If is_delayed, run a timer first
	if is_delayed:
		$Timer.start()
		await $Timer.timeout
	# Depending on type of invader, call the right function in the region
	if region.explorers.has(token):
		region.destroy_explorer(token)
	elif region.towns.has(token):
		region.destroy_town(token)
		await fear_board.generate_fear(1)
		
	else:
		region.destroy_city(token)
		await fear_board.generate_fear(2)

func destroy_dahan(region, token, is_delayed):
	# Set the texture to reflect destruction
	token.set_destroyed()
	# If is_delayed, run a timer first
	if is_delayed:
		$Timer.start()
		await $Timer.timeout
	region.destroy_dahan(token)

# Genarlized functions for removing tokens
func remove_blight(region, token, is_delayed):
	# Set the texture to reflect destruction
	token.set_removed()
	if is_delayed:
		$Timer.start()
		await $Timer.timeout
	region.remove_blight(token)

# Currently uses set_destroyed method, could update if using diff texture
func remove_invader(region, token, is_delayed):
	# Set the texture to reflect destruction
	token.set_destroyed()
	if is_delayed:
		$Timer.start()
		await $Timer.timeout
	if region.explorers.has(token):
		region.remove_explorer(token)
	elif region.towns.has(token):
		region.remove_town(token)
	else:
		region.remove_city(token)

# Currently uses set_destroyed method, could update if using diff texture
func remove_dahan(region, token, is_delayed):
	# Set the texture to reflect destruction
	token.set_destroyed()
	if is_delayed:
		$Timer.start()
		await $Timer.timeout
	region.remove_dahan(token)

# Generalized functions for pushing tokens
func push_invader(region, token, new_region, is_delayed):
	if is_delayed:
		$Timer.start()
		await $Timer.timeout
	if region.explorers.has(token):
		region.remove_explorer(token)
		new_region.add_explorer(token)
	elif region.towns.has(token):
		region.remove_town(token)
		new_region.add_town(token)
	else:
		region.remove_city(token)
		new_region.add_city(token)

func push_dahan(region, token, new_region, is_delayed):
	if is_delayed:
		$Timer.start()
		await $Timer.timeout
	region.remove_dahan(token)
	new_region.add_dahan(token)

# User input functions
func token_clicked(token):
	active_token_selected.emit(token)

func region_clicked(region):
	active_region_selected.emit(region)

func region_entered(region):
	active_region_entered.emit(region)

func region_exited(region):
	active_region_exited.emit(region)
