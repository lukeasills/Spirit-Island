extends HFlowContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_next_position():
	var token_size = Vector2(64,64)
	var children_count = get_child_count()
	var new_position = Vector2(0,0)
	if alignment == ALIGNMENT_CENTER:
		new_position.x = size.x/2 - token_size.x/2
		for i in children_count:
			new_position.x += token_size.x / 2
			if i > 1:
				new_position.x += 4
			if new_position.x + token_size.x > size.x:
				new_position.y += (token_size.y + 4)
				new_position.x = size.x/2 - token_size.x/2
	elif alignment == ALIGNMENT_BEGIN:
		for i in children_count:
			new_position.x += token_size.x
			if i > 1:
				new_position.x += 4
			if new_position.x + token_size.x > size.x:
				new_position.y += (token_size.y + 4)
				new_position.x = 0
	return new_position
