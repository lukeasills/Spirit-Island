extends CenterContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_text(new_text):
	$Label.text = new_text
	$Label.visible = true

func turn_off_text():
	$Label.visible = false

func turn_on_text():
	$Label.visible = true
	
func _on_invader_board_explore_initiated(land_type):
	set_text("Exploring...")

func _on_invader_board_build_initiated(land_type):
	set_text("Building...")

func _on_invader_board_ravage_initiated(land_type):
	set_text("Ravaging...")
	
func _on_main_built():
	turn_off_text()

func _on_main_explored():
	turn_off_text()

func _on_main_ravaged():
	turn_off_text()
