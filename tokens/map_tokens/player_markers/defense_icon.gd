class_name defense_icon
extends "res://tokens/map_tokens/token.gd"

var defense_total

# Called when the node enters the scene tree for the first time.
func _ready():
	defense_total = 0
	token_ready()

func set_amount(how_much):
	if how_much == 0:
		visible = false
	else:
		visible = true
	defense_total = how_much
	$Label.text = str(defense_total)

func preview_amount(how_much):
	visible = true
	$Label.text = str(how_much)

func end_preview():
	if defense_total == 0:
		visible = false
	$Label.text = str(defense_total)
