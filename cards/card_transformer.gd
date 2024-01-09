extends MarginContainer

@export var card_scene: PackedScene

var is_moving
var start_position
var end_position
var end_scale
var is_scaling
var end_fade
var is_fading

@export var default_speed: Vector2
var speed
@export var default_scale_speed: Vector2
var scale_speed
@export var default_fade_speed: float
var fade_speed

signal transformed

# Called when the node enters the scene tree for the first time.
func _ready():
	is_moving = false
	is_scaling = false
	is_fading = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_moving && !is_scaling && !is_fading:
		position = Vector2(-100, -100)
		transformed.emit(end_position)
		return
	if is_moving:
		if speed.x == 0 && speed.y == 0:
			is_moving = false
		if speed.x != 0:
			if speed.x < 0:
				if position.x + speed.x * delta <= end_position.x:
					position.x = end_position.x
					speed.x = 0
			else:
				if position.x + speed.x *delta >= end_position.x:
					position.x = end_position.x
					speed.x = 0
		if speed.y != 0:
			if speed.y < 0:
				if position.y + speed.y * delta <= end_position.y:
					position.y = end_position.y
					speed.y = 0
			else:
				if position.y + speed.y *delta >= end_position.y:
					position.y = end_position.y
					speed.y = 0
	if is_moving:
		position += speed
	if is_scaling:
		if scale_speed.x == 0 && scale_speed.y == 0:
			is_scaling = false
		if scale_speed.x != 0:
			if scale_speed.x < 0:
				if scale.x + scale_speed.x * delta <= end_scale.x:
					scale.x = end_scale.x
					scale_speed.x = 0
			else:
				if scale.x + scale_speed.x *delta >= end_scale.x:
					scale.x = end_scale.x
					scale_speed.x = 0
		if scale_speed.y != 0:
			if scale_speed.y < 0:
				if scale.y + scale_speed.y * delta <= end_scale.y:
					scale.y = end_scale.y
					scale_speed.y = 0
			else:
				if scale.y + scale_speed.y *delta >= end_scale.y:
					scale.y = end_scale.y
					scale_speed.y = 0
	if is_scaling:
		scale += scale_speed
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
func init_move(start, end, init_speed = default_speed, in_sync = true):
	position = start
	end_position = end
	speed = init_speed
	if speed.x != 0 && speed.y != 0 && in_sync:
		var ratio = (end.y - start.y) / abs(end.x - start.x)
		speed.y = ratio * abs(speed.x)
	is_moving = true

func init_scale(start, end, init_scale_speed = default_scale_speed, in_sync_with_move = true):
	scale = start
	end_scale = end
	scale_speed = init_scale_speed
	if (speed.x != 0 || speed.y != 0) && in_sync_with_move:
		if speed.x != 0:
			var ratio = (end - start) / abs(end_position.x - position.x)
			scale_speed = ratio * abs(speed.x)
		else:
			var ratio = (end - start) / abs(end_position.y - position.y)
			scale_speed = ratio * abs(speed.y)
	is_scaling = true

func init_fade(start, end, init_fade_speed = default_fade_speed):
	modulate.a = start
	end_fade = end
	fade_speed = init_fade_speed
	is_fading = true

# Attach new card
func attach(new_card):
	modulate.a = new_card.modulate.a
	add_child(new_card)

# Remove card from children, send it back as return value
func detach():
	var old_card = get_children()[0]
	remove_child(old_card)
	return old_card
