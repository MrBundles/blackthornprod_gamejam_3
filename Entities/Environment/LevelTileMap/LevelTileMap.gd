tool
extends TileMap

#variables
var flipped = false setget set_flipped
export var color = GlobalColorManager.level_palette[0] setget set_color
export var color_flipped = GlobalColorManager.level_palette[2]
export var collision = true setget set_collision

func _ready():
	#connect signals
	GlobalSignalManager.connect("dig_tile_request", self, "_on_dig_tile_request")
	GlobalSignalManager.connect("dig_tile_confirm", self, "_on_dig_tile_confirm")
	GlobalSignalManager.connect("flip_world_request", self, "_on_flip_world_request")
	GlobalSignalManager.connect("flip_world_confirm", self, "_on_flip_world_confirm")
	
	self.flipped = false
	self.color = color
	self.collision = collision


func _on_dig_tile_request(dig_tile_pos):
	if collision:
		var dig_tile_pos_map = world_to_map(dig_tile_pos)
		set_cell(dig_tile_pos_map.x, dig_tile_pos_map.y, -1)
		GlobalSignalManager.emit_signal("dig_tile_confirm", dig_tile_pos)



func _on_dig_tile_confirm(dig_tile_pos):
	if not collision:
		var dig_tile_pos_map = world_to_map(dig_tile_pos)
		set_cell(dig_tile_pos_map.x, dig_tile_pos_map.y, 5)


func _on_flip_world_request(flip_tile_pos):
	if collision:
		var flip_til_pos_map = world_to_map(flip_tile_pos)
		if get_cell(flip_til_pos_map.x, flip_til_pos_map.y) == 5:
			GlobalSignalManager.emit_signal("flip_world_confirm", flip_tile_pos)


func _on_flip_world_confirm(flip_tile_pos):
	self.flipped = !flipped
	self.collision = !collision


func set_flipped(new_val):
	flipped = new_val
	
	var tween_duration = .5
	var tween_transition = Tween.TRANS_EXPO
	var tween_easing = Tween.EASE_IN
	
	if flipped:
		$Tween.interpolate_property(self, "modulate", modulate, color_flipped, 
		tween_duration, tween_transition, tween_easing)
	else:
		$Tween.interpolate_property(self, "modulate", modulate, color, 
		tween_duration, tween_transition, tween_easing)
	
	$Tween.start()


func set_color(new_val):
	color = new_val
	
	modulate = color


func set_collision(new_val):
	collision = new_val
	
	if collision:
		set_collision_layer_bit(0, true)
		z_index = 0
	else:
		set_collision_layer_bit(0, false)
		z_index = 1
