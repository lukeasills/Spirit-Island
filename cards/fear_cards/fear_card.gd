class_name fear_card

extends "res://cards/card_effects.gd"

var card_front = load("res://art/cards/fear/FearCardFront.png")
var card_back = load("res://art/cards/fear/FearCardBack.png")
var card_back_lit = load("res://art/cards/fear/FearCardBackLit.png")

@onready var revealed = false

var level1_effect_text
var level2_effect_text
var level3_effect_text 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func fear_card_on_ready():
	$TextureButton.texture_normal = card_back
	$Title.visible = false
	$FearLevel1Text.visible = false
	$FearLevel2Text.visible = false
	$FearLevel3Text.visible = false
	card_effects_on_ready()

# Base function for resolving effects. In fear cards, determine which level
func resolve_effects(fear_level):
	if fear_level == 1:
		LabelContainer.set_text(level1_effect_text)
		await resolve_level1_effects()
	elif fear_level == 2:
		LabelContainer.set_text(level2_effect_text)
		await resolve_level2_effects()
	else:
		LabelContainer.set_text(level3_effect_text)
		await resolve_level3_effects()
	LabelContainer.turn_off_text()

func resolve_level1_effects():
	pass

func resolve_level2_effects():
	pass

func resolve_level3_effects():
	pass

func card_pressed():
	get_parent().card_pressed(self)

func activate():
	get_node("TextureButton").disabled = false

func deactivate():
	get_node("TextureButton").disabled = true

func reveal():
	if !revealed:
		flip()

func flip():
	revealed = !revealed
	$Title.visible = !$Title.visible
	$FearLevel1Text.visible = !$FearLevel1Text.visible
	$FearLevel2Text.visible = !$FearLevel2Text.visible
	$FearLevel3Text.visible = !$FearLevel3Text.visible
	if revealed:
		get_node("TextureButton").texture_normal = card_front
	else:
		get_node("TextureButton").texture_normal = card_back

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_texture_button_pressed():
	card_pressed()
