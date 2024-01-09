extends ReferenceRect
signal fear_pool_empty


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Generate one fear at a time
func generate_fear(is_delayed):
	var fear = $FearPoolContainer.get_children()[0]
	var init_pos = fear.position + $FearPoolContainer.position
	var end_pos = $GeneratedFearContainer.position + $GeneratedFearContainer.get_next_position()
	$FearPoolContainer.remove_child(fear)
	$FearTransformer.attach(fear)
	$FearTransformer.init_move(init_pos, end_pos)
	await $FearTransformer.transformed
	fear = $FearTransformer.detach()
	$GeneratedFearContainer.add_child(fear)
	
	if is_delayed:
		$GenerateFearTimer.start()
		await $GenerateFearTimer.timeout
	
	# If ever empty... reset!
	if $FearPoolContainer.get_child_count() == 0:
		return true
	else:
		return false

# Reset fear pool by moving all children of generated pool back to fear pool
func reset_fear_pool():
	while $GeneratedFearContainer.get_child_count() > 0:
		var fear = $GeneratedFearContainer.get_children()[0]
		var init_pos = fear.position + $GeneratedFearContainer.position
		var end_pos = $FearPoolContainer.position + $FearPoolContainer.get_next_position()
		$GeneratedFearContainer.remove_child(fear)
		$FearTransformer.attach(fear)
		$FearTransformer.init_move(init_pos, end_pos, 0.1)
		await $FearTransformer.transformed
		fear = $FearTransformer.detach()
		$FearPoolContainer.add_child(fear)
