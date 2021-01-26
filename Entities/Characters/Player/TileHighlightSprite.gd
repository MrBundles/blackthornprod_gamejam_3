tool
extends Sprite

#get references
onready var tilemap = get_parent().get_node("PlayerTileMap")

#variables
var active = false setget set_active
export var min_highlight_distance = 72

export var color = Color8(0,0,0,255)
export var highlight_color = Color8(0,0,0,255)
export var center_color = Color8(0,0,0,255)


func _process(delta):
	if not Engine.editor_hint:
		self.active = global_position.distance_to(get_parent().global_position) < min_highlight_distance
		get_input()
		update_position()
	
	$Foreground.modulate = center_color


func set_active(new_val):
	if active != new_val:
		active = new_val
		
		if active:
			modulate = highlight_color
		else:
			modulate = color


func get_input():
	if active:
		pass


func update_position():
	var offset = Vector2(32,32)
	global_position = tilemap.map_to_world(tilemap.world_to_map(get_global_mouse_position())) + offset
