extends MarginContainer

@export var card_scene: PackedScene

var moving
var start_position
var end_position

@export var speed: Vector2
var horizontal: bool
var negative: bool

signal moved

# Called when the node enters the scene tree for the first time.
func _ready():
	moving = false
	horizontal = speed.x != 0
	negative = speed.x < 0 || speed.y < 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if moving:
		if horizontal:
			if negative:
				if position.x + speed.x * delta <= end_position.x:
					position.x = end_position.x
					moving = false
					moved.emit(end_position)
			else:
				if position.x + speed.x *delta >= end_position.x:
					position.x = end_position.x
					moving = false
					moved.emit(end_position)
		else:
			if negative:
				if position.y + speed.y * delta <= end_position.y:
					position.x = end_position.x
					moving = false
					moved.emit(end_position)
			else:
				if position.y + speed.y *delta >= end_position.y:
					position.y = end_position.y
					moving = false
					moved.emit(end_position)
	if moving:
		position += speed

# Set start and end position, set moving to true
func move(start, end):
	start_position = start
	position = start_position
	end_position = end
	moving = true

# Attach new card
func attach(new_card):
	add_child(new_card)

# Remove card from children, send it back as return value
func detach():
	var old_card = get_children()[0]
	remove_child(old_card)
	return old_card
