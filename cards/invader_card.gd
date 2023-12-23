extends MarginContainer

var stage
@export var land_types: Array[String]
@export var front_texture: Texture

# Called when the node enters the scene tree for the first time.
func _ready():
	var path = str("res://art/cards/invaders/backs/Invader",stage,"CardBack.png")
	$CardBase.set("card_back_texture", path)
	$CardBase.texture_normal = front_texture

func _process(delta):
	pass

func set_types(types):
	land_types = types
