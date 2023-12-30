class_name fear_card_base

extends "res://cards/card_effects.gd"

@export var card_front: Texture2D
var card_back = load("res://art/cards/fear/FearCardBack.png")

var revealed

# Called when the node enters the scene tree for the first time.
func _ready():
	revealed = false
	print(LandMap)

# Base function for resolving effects. In fear cards, determine which level
func resolve_effects(fear_level):
	if fear_level == 1:
		resolve_level1_effects()
	elif fear_level == 2:
		resolve_level2_effects()
	else:
		resolve_level3_effects()

func resolve_level1_effects():
	pass

func resolve_level2_effects():
	pass

func resolve_level3_effects():
	pass

func reveal():
	if !revealed:
		flip()

func flip():
	revealed = !revealed
	if revealed:
		get_node("TextureButton").texture_normal = card_front
	else:
		get_node("TextureButton").texture_normal = card_back

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
