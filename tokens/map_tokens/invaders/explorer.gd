class_name explorer
extends "res://tokens/map_tokens/token.gd"

@export var normal_texture: Texture2D
@export var destroyed_texture: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Set selectable by player for distributing damage
func set_active_for_damage():
	$TextureButton.texture_hover = destroyed_texture
	$TextureButton.texture_pressed = destroyed_texture
	set_active()

# Set selectable by player for distributing damage
func set_active_for_destruction():
	set_active_for_damage()

# Set selectable by player for distributing damage
func set_active_for_removal():
	set_active_for_destruction()

func set_destroyed():
	$TextureButton.texture_normal = destroyed_texture

func _on_texture_button_pressed():
	if !$TextureButton.disabled:
		get_parent().get_parent().token_selected(self)

func _on_texture_button_mouse_entered():
	if !$TextureButton.disabled:
		get_parent().get_parent().token_hovered(self)

func _on_texture_button_mouse_exited():
	if !$TextureButton.disabled:
		get_parent().get_parent().stop_token_hovered(self)
