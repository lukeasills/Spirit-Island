extends Node
signal invader_actions_completed

signal ravage_initiated
signal build_initiated
signal explore_initiated

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func initiate_invader_actions():
	# From ravage space to discard space
	var old_ravage_card = $RavageSpace.detach()
	# Check if there is something in RavageSpace...
	if old_ravage_card != null:
		$InvaderCardMover.attach(old_ravage_card)
		$InvaderCardMover.move($RavageSpace.position, $DiscardSpace.position)
		await $InvaderCardMover.moved	
		old_ravage_card = $InvaderCardMover.detach()
		$DiscardSpace.attach(old_ravage_card)
		
	# From build space to ravage space
	var old_build_card = $BuildSpace.detach()
	# Check if there is something in BuildSpace...
	if old_build_card != null:
		$InvaderCardMover.attach(old_build_card)
		$InvaderCardMover.move($BuildSpace.position, $RavageSpace.position)
		await $InvaderCardMover.moved
		old_build_card = $InvaderCardMover.detach()
		$RavageSpace.attach(old_build_card)
		ravage_initiated.emit(old_build_card.land_types)
		await get_parent().ravaged
	
	# From explore space to build space
	var old_explore_card = $ExploreSpace.detach()
	# Check if there is something in RavageSpace...
	if old_explore_card != null:
		$InvaderCardMover.attach(old_explore_card)
		$InvaderCardMover.move($ExploreSpace.position, $BuildSpace.position)
		await $InvaderCardMover.moved
		old_explore_card = $InvaderCardMover.detach( )
		print(old_explore_card)
		$BuildSpace.attach(old_explore_card)
		build_initiated.emit(old_explore_card.land_types)
		await get_parent().built
	
	# From deck to explore space
	if !get_parent().invader_deck_empty:
		var drawn_card = $InvaderDeck.draw()
		$InvaderCardMover.attach(drawn_card)
		$InvaderCardMover.move($InvaderDeck.position, $ExploreSpace.position)
		await $InvaderCardMover.moved
		drawn_card = $InvaderCardMover.detach()
		$ExploreSpace.attach(drawn_card)
		explore_initiated.emit(drawn_card.land_types)
		await get_parent().explored
	invader_actions_completed.emit()
	get_tree().call_group("dahan", "reset_damage")
	get_tree().call_group("towns", "reset_damage")
	get_tree().call_group("cities", "reset_damage")
	
	

