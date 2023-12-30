extends ReferenceRect


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Add card to CardContainer (REVIEW: WHY DO I NEED CARDCONTAINER / WHY NOT MARGINS?)
func attach(new_card):
	#new_card.position = position
	add_child(new_card)

# Remove card from children and send back as return value
func detach(card = null):
	if card != null:
		remove_child(card)
		return card
	if get_child_count() == 1:
		return null
	var old_card = get_children()[1]
	if (old_card!=null):
		remove_child(old_card)
	return old_card

func is_empty():
	if get_child_count() > 1:
		return false
	else:
		return true

func get_oldest_card():
	if get_child_count() > 1:
		var card = get_children()[1]
		return card
