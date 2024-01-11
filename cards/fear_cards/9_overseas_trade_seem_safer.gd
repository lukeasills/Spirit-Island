class_name overseas_trade_seem_safer
extends "res://cards/fear_cards/fear_card.gd"

func _ready():
	fear_card_on_ready()
	level1_effect_text = "Defend 3 in all Coastal lands."
	level2_effect_text = "Defend 6 in all Coastal lands. Invaders do not Build Cities in Coastal lands this turn."
	level3_effect_text  = "Defend 9 in all Coastal lands. Invaders do not Build in Coastal lands this turn."

func resolve_level1_effects(active_option=0):
	var regions = Main.get_coastal_land()
	await Main.defend(regions, "constant", 3)

func resolve_level2_effects(active_option=0):
	var regions = Main.get_coastal_land()
	await Main.defend(regions, "constant", 6)
	await Main.block_invader_actions(regions, [false, [false, true], false])

func resolve_level3_effects(active_option=0):
	var regions = Main.get_coastal_land()
	await Main.defend(regions, "constant", 9)
	await Main.block_invader_actions(regions, [false, [true, true], false])
