extends MarginContainer
var invader_type: String: set = set_invader_type

func _ready():
	pass

func set_invader_type(type):
	invader_type = type
	var path = str("res://art/tokens/",type,".png")
	$TextureButton.texture_normal = load(path)
	
