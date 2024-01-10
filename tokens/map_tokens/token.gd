class_name token
extends Control

var active
signal selected
signal hovered
signal end_hovered

var fading
var fade_speed
signal faded

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func token_ready():
	active = false
	selected.connect(get_tree().get_root().get_node("Main").on_token_selected.bind(self))
	hovered.connect(get_tree().get_root().get_node("Main").on_token_hovered.bind(self))
	end_hovered.connect(get_tree().get_root().get_node("Main").on_token_end_hovered.bind(self))


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
	active = true

func set_inactive():
	$TextureButton.disabled = true
	active = false

func init_fade(speed = -0.1):
	fade_speed = speed
	fading = true


func _on_texture_button_pressed():
	selected.emit()

func _on_texture_button_mouse_entered():
	hovered.emit()

func _on_texture_button_mouse_exited():
	end_hovered.emit()
