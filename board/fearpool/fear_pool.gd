extends ReferenceRect
signal fear_pool_empty


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Generate one fear at a time
func generate_fear():
	var fear = $FearPoolContainer.get_children()[0]
	$FearPoolContainer.remove_child(fear)
	$GeneratedFearContainer.add_child(fear)
	
	# If ever empty... reset!
	if $FearPoolContainer.get_child_count() == 0:
		return true
	else:
		return false

# Reset fear pool by moving all children of generated pool back to fear pool
func reset_fear_pool():
	while $GeneratedFearContainer.get_child_count() > 0:
		var fear = $GeneratedFearContainer.get_children()[0]
		$GeneratedFearContainer.remove_child(fear)
		$FearPoolContainer.add_child(fear)
