extends Button
signal skip_button_pressed

# Called when the node enters the scene tree for the first time.
func _ready():
	skip_button_pressed.connect(get_tree().get_root().get_node("Main").on_skip_button_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
