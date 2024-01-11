extends TextureButton

var is_selected
signal selected
@export var UnfilledTexture: Texture2D
@export var FilledTexture: Texture2D

@export var option_number:int
# Called when the node enters the scene tree for the first time.
func _ready():
	selected.connect(get_tree().get_root().get_node("Main").on_option_button_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func hide_button():
	disabled = true
	visible = false

func select():
	is_selected = true
	texture_normal = FilledTexture
	for option_button in get_parent().get_children():
		if option_button.option_number != option_number:
			option_button.deselect()

func deselect():
	if is_selected:
		is_selected = false
		texture_normal = UnfilledTexture

func _on_pressed():
	if !is_selected:
		select()
		selected.emit(option_number)
	
