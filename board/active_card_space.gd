extends ReferenceRect
signal continue_pressed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func attach_fear_card(fear_card, fear_level):
	$CardContainer.add_child(fear_card)
	scale = Vector2(2.2, 2.2)
	highlight_fear_level(fear_level)

func highlight_fear_level(level):
	if level == 1:
		$FearLevel1Highlight.visible = true
	elif level == 2:
		$FearLevel2Highlight.visible = true
	else:
		$FearLevel3Highlight.visible = true 

func unhighlight_fear_level():
	$FearLevel1Highlight.visible = false
	$FearLevel2Highlight.visible = false
	$FearLevel3Highlight.visible = false
		
func attach_power_card(power_card):
	pass

func enable_skip_button():
	$ContinueButton.disabled = false
	$ContinueButton.visible = true

func disable_skip_button():
	$ContinueButton.disabled = true
	$ContinueButton.visible = false

func detach_fear_card():	
	disable_skip_button()
	unhighlight_fear_level()
	var card = detach_card()
	return card

func detach_card():
	var card = $CardContainer.get_children()[0]
	$CardContainer.remove_child(card)
	return card

func _on_continue_button_pressed():
	continue_pressed.emit()
