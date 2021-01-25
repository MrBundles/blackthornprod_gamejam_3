tool
extends TileMap

#variables
export var color = GlobalColorManager.level_palette[0] setget set_color

func _ready():
	self.color = color


func set_color(new_val):
	color = new_val
	
	modulate = color
