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
	
func _on_invader_board_explore_initiated(regions=null):
	set_text("Exploring...")
	if regions != null:
		set_text("Exploring the "+regions+"...")

func _on_invader_board_build_initiated(regions=null):
	set_text("Building...")
	if regions != null:
		set_text("Building in the "+regions+"...")

func _on_invader_board_ravage_initiated(regions=null):
	set_text("Ravaging...")
	if regions != null:
		set_text("Ravaging the "+regions+"...")
	
func _on_invader_board_built():
	turn_off_text()

func _on_invader_board_explored():
	turn_off_text()

func _on_invader_board_ravaged():
	turn_off_text()

func _on_fear_board_initiate_resolve_earned_fear_cards():
	set_text("Resolve earned fear cards.")

func _on_fear_board_fear_cards_resolved():
	turn_off_text()

func _on_earned_fear_cards_spot_initiate_resolve_fear_card_effect(text):
	set_text(text)

func _on_earned_fear_cards_spot_fear_card_effect_resolved():
	turn_off_text()

func _on_invader_board_blight_cascade_initiated():
	set_text("Blight cascades! Choose a region.")

func _on_invader_board_blight_cascade_resolved():
	turn_off_text()

func _on_invader_board_dahan_fight_back_initiated(damage):
	set_text(str("The Dahan fight back! Distribute ",damage," damage"))

func _on_invader_board_dahan_fight_back_resolved():
	turn_off_text()
