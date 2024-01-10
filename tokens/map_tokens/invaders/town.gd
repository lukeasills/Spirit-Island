class_name town
extends "res://tokens/map_tokens/token.gd"

var damaged
@export var normal_texture: Texture2D
@export var damaged_texture: Texture2D
@export var destroyed_texture: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready():
	damaged = false
	token_ready()

# Set selectable by player for distributing damage
func set_active_for_damage():
	if damaged:
		$TextureButton.texture_hover = destroyed_texture
		$TextureButton.texture_pressed = destroyed_texture
	else:
		$TextureButton.texture_hover = damaged_texture
		$TextureButton.texture_pressed = damaged_texture
	set_active()

func set_active_for_destruction():
	$TextureButton.texture_hover = destroyed_texture
	$TextureButton.texture_pressed = destroyed_texture
	set_active()

func set_active_for_removal():
	set_active_for_destruction()

# Set town into damaged mode
func set_damaged():
	damaged = true
	$TextureButton.texture_normal = damaged_texture

# Reset to non-damaged mode
func reset_damage():
	damaged = false
	$TextureButton.texture_normal = normal_texture

func set_destroyed():
	$TextureButton.texture_normal = destroyed_texture
