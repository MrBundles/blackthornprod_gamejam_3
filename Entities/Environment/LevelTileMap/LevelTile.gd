extends StaticBody2D

#enums
enum TILE_STATES {Active, Solid, Inactive, Bad, Good}

#variables
export var color_array = [
	Color8(255,255,255,255),
	Color8(255,255,255,255),
	Color8(255,255,255,255),
	Color8(255,255,255,255),
	Color8(255,255,255,255)
]

export(TILE_STATES) var tile_state = TILE_STATES.Active setget set_tile_state
var offset = Vector2(32,32)
var mouse_present = false setget set_mouse_present
var player_present = false setget set_player_present
export(Curve) var delay_curve = Curve.new()

func _ready():
	#connect signals
	GlobalSignalManager.connect("flip_world", self, "_on_flip_world")
	
	self.tile_state = tile_state
	self.mouse_present = mouse_present


func _on_flip_world(flip_tile_pos):
	if tile_state == TILE_STATES.Active or tile_state == TILE_STATES.Inactive:
		var max_distance = Vector2.ZERO.distance_to(get_viewport().get_visible_rect().size)		
		var delay = delay_curve.interpolate((global_position + offset).distance_to(flip_tile_pos) / max_distance)
		yield(get_tree().create_timer(delay), "timeout")
		
		if tile_state == TILE_STATES.Active:
			self.tile_state = TILE_STATES.Inactive
		else:
			self.tile_state = TILE_STATES.Active


func _process(delta):
	self.mouse_present = mouse_in_tile(get_global_mouse_position())
	self.player_present = player_in_range(GlobalVariableManager.player_position)
	get_input()


func mouse_in_tile(mouse_pos):
	return mouse_pos.x > global_position.x and mouse_pos.x < global_position.x + 64 and mouse_pos.y > global_position.y and mouse_pos.y < global_position.y + 64


func player_in_range(player_pos):
	var min_player_distance = 96
	return (global_position + offset).distance_to(player_pos) < min_player_distance


func get_input():
	if tile_state == TILE_STATES.Active and mouse_present and player_present:
		if Input.is_action_pressed("mouse_left_click"):
			self.tile_state = TILE_STATES.Inactive
		
		if Input.is_action_just_pressed("mouse_right_click"):
			GlobalSignalManager.emit_signal("flip_world", global_position + offset)


func set_tile_state(new_val):
	if tile_state != new_val:
		tile_state = new_val
		
		#set tile color
		$CenterSprite.modulate = color_array[tile_state]
		
		#set tile collision and center sprite scaling
		if tile_state == TILE_STATES.Active or tile_state == TILE_STATES.Solid:
			set_collision_layer_bit(0, true)
			set_collision_mask_bit(0, true)
		else:
			set_collision_layer_bit(0, false)
			set_collision_mask_bit(0, false)
			$Tween.stop_all()
			$CenterSprite.scale = Vector2(1,1)
	
	
func set_mouse_present(new_val):
	if mouse_present != new_val:
		mouse_present = new_val
		
		if mouse_present:
			$BorderSprite.modulate = color_array[4]
		else:
			$BorderSprite.modulate = color_array[2]



func set_player_present(new_val):
	if player_present != new_val and tile_state == TILE_STATES.Active:
		player_present = new_val
	
		$Tween.stop_all()
		
		if player_present:
			$Tween.interpolate_property($CenterSprite, "scale", $CenterSprite.scale, Vector2(.85,.85),
			.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT
			)
		else:
			$Tween.interpolate_property($CenterSprite, "scale", $CenterSprite.scale, Vector2(1,1),
			.1, Tween.TRANS_BACK, Tween.EASE_IN
			)
		
		$Tween.start()




