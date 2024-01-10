class_name blight
extends "res://tokens/map_tokens/token.gd"

@export var removed_texture: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready():
	token_ready()

# Set selectable by player for removing
func set_active_for_removal():
	$TextureButton.texture_hover = removed_texture
	$TextureButton.texture_pressed = removed_texture
	set_active()

func set_removed():
	$TextureButton.texture_normal = removed_texture
