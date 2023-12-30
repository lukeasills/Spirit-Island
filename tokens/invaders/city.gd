extends MarginContainer

var damage
@export var normal_texture: Texture2D
@export var damaged1_texture: Texture2D
@export var damaged2_texture: Texture2D 
@export var destroyed_texture: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Set selectable by player for distributing damage
func set_active_for_damage():
	if damage == 0:
		$TextureButton.texture_hover = damaged1_texture
		$TextureButton.texture_pressed = damaged1_texture
	elif damage == 1:
		$TextureButton.texture_hover = damaged2_texture
		$TextureButton.texture_pressed = damaged2_texture
	else:
		$TextureButton.texture_hover = destroyed_texture
		$TextureButton.texture_pressed = destroyed_texture
	$TextureButton.disabled = false

func set_inactive():
	$TextureButton.disabled = true

# Set texture according to amount of damage taken
func set_damage(new_damage):
	damage = new_damage
	if damage == 1:
		$TextureButton.texture_normal = damaged1_texture
	elif damage == 2:
		$TextureButton.texture_normal = damaged2_texture

# Reset to non damaged mode
func reset_damage():
	damage = 0
	$TextureButton.texture_normal = normal_texture

func set_destroyed():
	$TextureButton.texture_normal = destroyed_texture

func _on_texture_button_pressed():
	get_parent().get_parent().token_selected(self)