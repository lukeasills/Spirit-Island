class_name token
extends Control

var fading
var fade_speed
signal faded

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if fading:
		if modulate.a + fade_speed * delta <= 0:
			modulate.a = 0
			fading = false
			faded.emit()
		else:
			modulate.a += fade_speed

func set_active():	
	$TextureButton.disabled = false

func set_inactive():
	$TextureButton.disabled = true

func init_fade(speed = -0.1):
	fade_speed = speed
	fading = true
