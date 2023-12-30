extends MarginContainer

var stage
@export var land_types: Array[String]
@export var front_texture: Texture2D
@export var card_back: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$TextureButton.texture_normal = front_texture

func _process(delta):
	pass

func set_types(types):
	land_types = types
