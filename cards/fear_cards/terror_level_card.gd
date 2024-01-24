extends TextureRect

@export var level: int

# Called when the node enters the scene tree for the first time.
func _ready():
	var text = "I"
	if level == 2:
		texture = load("res://art/cards/fear/TerrorLevel2.png")
		text = "II"
	elif level == 3:
		texture = load("res://art/cards/fear/TerrorLevel3.png")
		text = "III"
	$NumberLabel.text = text

func get_level():
	if $NumberLabel.text == "I":
		return 1
	elif $NumberLabel.text == "II":
		return 2
	else:
		return 3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
