extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# 
func attach(new_card):
	var offset = Vector2((new_card.size.y - new_card.size.x)/2,(new_card.size.x - new_card.size.y)/2)
	new_card.position = self.position + offset + Vector2(5,5)
	new_card.rotation_degrees = 270
	$CardSpace/CardContainer.add_child(new_card)
