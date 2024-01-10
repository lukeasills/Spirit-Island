class_name dahan
extends "res://tokens/map_tokens/token.gd"

var damaged
@export var normal_texture: Texture2D
@export var damaged_texture: Texture2D
@export var destroyed_texture: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready():
	damaged = false
	token_ready()

# Set dahan to "damaged" mode
func set_damaged():
	damaged = true
	$TextureButton.texture_normal = damaged_texture

# Reset to non damaged mode
func reset_damage():
	damaged = false
	$TextureButton.texture_normal = normal_texture

# Set texture to destroyed texture
func set_destroyed():
	$TextureButton.texture_normal = destroyed_texture

# Set selectable by player for removing
func set_active_for_removal():
	$TextureButton.texture_hover = destroyed_texture
	$TextureButton.texture_pressed = destroyed_texture
	set_active()
