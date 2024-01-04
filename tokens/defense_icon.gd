extends MarginContainer

var defense_total

# Called when the node enters the scene tree for the first time.
func _ready():
	defense_total = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_amount(how_much):
	if how_much == 0:
		visible = false
	else:
		visible = true
	defense_total = how_much
	$Label.text = str(defense_total)

func preview_amount(how_much):
	visible = true
	$Label.text = str(how_much)

func end_preview():
	if defense_total == 0:
		visible = false
	$Label.text = str(defense_total)
