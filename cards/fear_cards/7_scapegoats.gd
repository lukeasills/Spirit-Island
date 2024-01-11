class_name scapegoats
extends "res://cards/fear_cards/fear_card.gd"

func _ready():
	fear_card_on_ready()
	level1_effect_text = "Each Town destroys 1 Explorer in its land."
	level2_effect_text = "Each Town destroys 1 Explorer in its land. Each City destroys 2 Explorers in its land"
	level3_effect_text  = "Destroy all Explorers in lands with Towns or Cities. Each City destroys 1 Town in its land."

func resolve_level1_effects(active_option=0):
	var regions = Main.get_land_with_invaders()
	# In each region
	for region in regions:
		region.set_lit()
		# If there are towns and explorers...
		if region.towns.size() > 0 && region.explorers.size() > 0:
			# Each town destroys an explorer
			for i in region.towns.size():
				if region.explorers.size() >= 0:
					await Main.destroy_invader(region, region.explorers[0], true)
		region.set_unlit()

func resolve_level2_effects(active_option=0):
	var regions = Main.get_land_with_invaders()
	# In each region
	for region in regions:
		region.set_lit()
		# If there are towns and explorers...
		if region.towns.size() > 0 && region.explorers.size() > 0:
			# Each town destroys an explorer
			for i in region.towns.size():
				if region.explorers.size() >= 0:
					await Main.destroy_invader(region, region.explorers[0], true)
		# If there are cities and explorers...
		if region.cities.size() > 0 && region.explorers.size() > 0:
			# Each city destroys 2 explorers
			for i in region.cities.size():
				if region.explorers.size() > 0:
					await Main.destroy_invader(region, region.explorers[0], true)
				if region.explorers.size() > 0:
					await Main.destroy_invader(region, region.explorers[0], true)
		region.set_unlit()

func resolve_level3_effects(active_option=0):
	var regions = Main.get_land_with_invaders()
	# In each region
	for region in regions:
		region.set_lit()
		# If there are towns / cities and explorers...
		if (region.towns.size() > 0 || region.cities.size()) && region.explorers.size() > 0:
			# Destroy all explorers
			while region.explorers.size() > 0:
				await Main.destroy_invader(region, region.explorers[0], true)
		# If there are cities and towns...
		if region.cities.size() > 0 && region.towns.size() > 0:
			# Each city destroys 1 town
			for i in region.cities.size():
				if region.towns.size() >= 0:
					await Main.destroy_invader(region, region.towns[0], true)
		region.set_unlit()
