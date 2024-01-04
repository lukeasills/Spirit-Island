extends MarginContainer

@export var amount: int = 0
var is_present
var is_holy_site

# Called when the node enters the scene tree for the first time.
func _ready():
	set_amount(amount)

func add_presence(to_add):
	set_amount(amount + to_add)

func remove_presence(to_remove):
	set_amount(amount - to_remove)

func set_amount(now_total):
	amount = now_total
	$Label.text = str(amount)
	
	visible = false
	$Label.visible = false
	is_holy_site = false
	is_present = false
	
	if amount > 0:
		visible = true
		is_present = true
		
	if amount > 1:
		$Label.visible = true
		is_holy_site = true
	
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
