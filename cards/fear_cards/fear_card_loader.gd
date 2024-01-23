extends Resource

@export var card_hard_list: Array[String]
@export var relative_path: String
var file_ending = ".tscn"

func get_cards(how_many):
	var cards = []
	for i in how_many:
		var index = randi() % card_hard_list.size()
		var path = relative_path + card_hard_list[index] + file_ending
		var card = load(path).instantiate()
		cards.append(card)
		card_hard_list.remove_at(index)
	return cards
		
