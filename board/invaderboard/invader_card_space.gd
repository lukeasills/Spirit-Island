extends VBoxContainer

@export var label_text: String

# Called when the node enters the scene tree for the first time.
func _ready():
	$TextLabel.text = label_text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Add card to CardContainer (REVIEW: WHY DO I NEED CARDCONTAINER / WHY NOT MARGINS?)
func attach(new_card):
	$CardSpace/CardContainer.add_child(new_card)

# Remove card from children and send back as return value
func detach():
	if $CardSpace/CardContainer.get_child_count() == 0:
		return null
	var old_card = $CardSpace/CardContainer.get_children()[0]
	if (old_card!=null):
		$CardSpace/CardContainer.remove_child(old_card)
	return old_card
