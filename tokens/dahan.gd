extends MarginContainer

var damaged
@export var normal_texture: Texture2D
@export var damaged_texture: Texture2D
@export var destroyed_texture: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready():
	damaged = false

# Set dahan to "damaged" mode
func set_damaged():
	damaged = true
	$TextureButton.texture_normal = damaged_texture

# Reset to non damaged mode
func reset_damage():
	damaged = false
	$TextureButton.texture_normal = normal_texture

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
