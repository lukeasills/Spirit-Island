extends MarginContainer
signal active_region_entered
signal active_region_selected
signal active_region_exited

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
	"Sand": Color(0.92, 0.77, 0.32, 0.8),
	"Mountain": Color(0.47, 0.46, 0.49, 0.8)
}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func region_clicked(region):
	active_region_selected.emit(region)

func region_entered(region):
	active_region_entered.emit(region)

func region_exited(region):
	active_region_exited.emit(region)
