extends MarginContainer

@export var removed_texture: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Set selectable by player for removing
func set_active_for_removal():
	$TextureButton.texture_hover = removed_texture
	$TextureButton.texture_pressed = removed_texture
	$TextureButton.disabled = false

func set_inactive():
	$TextureButton.disabled = true

func set_removed():
	$TextureButton.texture_normal = removed_texture


func _on_texture_button_pressed():
	get_parent().get_parent().token_selected(self)
