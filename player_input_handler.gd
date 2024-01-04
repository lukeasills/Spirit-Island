extends Node

signal skippable_selection_made

# Called when the node enters the scene tree for the first time.
func _ready():
	var LandMap = get_node("/root/Main/LandMap")
	LandMap.active_token_selected.connect(_on_land_map_token_selected)
	LandMap.active_region_selected.connect(_on_land_map_region_selected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func player_selection_made(args):
	skippable_selection_made.emit(args)

func _on_land_map_token_selected(args):
	var dict = {"skipped": false, "token":args["token"],"region":args["region"]}
	player_selection_made(dict)

func _on_land_map_region_selected(region):
	var dict = {"skipped": false, "region":region}
	player_selection_made(dict)
