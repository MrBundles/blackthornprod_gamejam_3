extends TileMap

#variables
var active = false setget set_active


func _ready():
	for tile_id in get_used_cells():
		var tile_instance = preload("res://Entities/Environment/LevelTileMap/LevelTile.tscn").instance()
		tile_instance.tile_state = get_cell(tile_id.x, tile_id.y)
		tile_instance.global_position = map_to_world(tile_id)
		$LevelTiles.add_child(tile_instance)
	
	clear()


func _process(delta):
	active


func set_active(new_val):
	if active != new_val:
		active = new_val
