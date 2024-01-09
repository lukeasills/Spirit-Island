extends MarginContainer

var is_moving
var start_position
var end_position
var end_fade
var is_fading

@export var default_move_duration: float
var move_duration
var speed
@export var default_fade_speed: float
var fade_speed

signal transformed

# Called when the node enters the scene tree for the first time.
func _ready():
	is_moving = false
	is_fading = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_moving && !is_fading:
		position = Vector2(-100, -100)
		transformed.emit(end_position)
		return
	if is_moving:
		var new_position = position + (delta * speed)
		if speed.x > 0 && new_position.x >= end_position.x:
			speed.x = 0
			new_position.x = end_position.x
		elif speed.x < 0 && new_position.x <= end_position.x:
			speed.x = 0
			new_position.x = end_position.x
		if speed.y > 0 && new_position.y >= end_position.y:
			speed.y = 0
			new_position.y = end_position.y
		elif speed.y < 0 && new_position.y <= end_position.y:
			speed.y = 0
			new_position.y = end_position.y
		position = new_position
		if speed.x == 0 && speed.y == 0:
			is_moving = false
	if is_fading:
		if fade_speed < 0:
			if modulate.a + fade_speed * delta <= end_fade:
				modulate.a = end_fade
				fade_speed = 0
				is_fading = false
		else:
			if modulate.a + fade_speed *delta >= end_fade:
				modulate.a = end_fade
				fade_speed = 0
				is_fading = false
	if is_fading:
		modulate.a += fade_speed

# Set start and end position, set moving to true
func init_move(start, end, move_d = default_move_duration):
	position = start
	end_position = end
	move_duration = move_d
	speed = (end - start) / move_duration
	print(position)
	is_moving = true

func init_fade(start, end, init_fade_speed = default_fade_speed):
	modulate.a = start
	end_fade = end
	fade_speed = init_fade_speed
	is_fading = true

# Attach new card
func attach(new_token):
	modulate.a = new_token.modulate.a
	add_child(new_token)

# Remove card from children, send it back as return value
func detach():
	var old_token = get_children()[0]
	remove_child(old_token)
	return old_token
