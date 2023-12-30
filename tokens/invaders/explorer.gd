extends MarginContainer

@export var normal_texture: Texture2D
@export var destroyed_texture: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Set selectable by player for distributing damage
func set_active_for_damage():
	$TextureButton.texture_hover = destroyed_texture
	$TextureButton.texture_pressed = destroyed_texture
	$TextureButton.disabled = false

func set_inactive():
	$TextureButton.disabled = true

func set_destroyed():
	$TextureButton.texture_normal = destroyed_texture


func _on_texture_button_pressed():
	get_parent().get_parent().token_selected(self)
