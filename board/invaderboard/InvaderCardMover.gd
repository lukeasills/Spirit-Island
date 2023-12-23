extends MarginContainer

@export var invader_card_scene: PackedScene

var moving
var start_position
var end_position

@export var speed: int

signal moved

# Called when the node enters the scene tree for the first time.
func _ready():
	moving = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var card = get_node_or_null("InvaderCard")
	if moving:
		print("moving!")
		print(card)
		if position.x - speed * delta <= end_position.x:
			position.x = end_position.x
			moving = false
			moved.emit(end_position)
		else:
			position += Vector2(-speed,0)

# Set start and end position, set moving to true
func move(start, end):
	start_position = start
	position = start_position
	end_position = end
	moving = true

# Attach new card
func attach(new_card):
	print("attached:")
	print(new_card)
	add_child(new_card)

# Remove card from children, send it back as return value
func detach():
	var old_card = get_children()[0]
	remove_child(old_card)
	return old_card
