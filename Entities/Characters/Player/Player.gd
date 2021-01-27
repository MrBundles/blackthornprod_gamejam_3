extends KinematicBody2D

#variables
export var color_player = Color8(0,0,0,255)
export var color_pause = Color8(255,255,255,255)
export var dig_count = 0
var init_dig_count

var velocity = Vector2(0,0)
export var velocity_transition = Vector2(-1000,0)
export var velocity_max = Vector2(5000,5000)
export var haccel = 1000
export var hdecel = 1000
export var jump = 1000
var jump_flag = false
export var gravity = 1000
var init_gravity = 0

var init_position = Vector2(0,0)

var flipped = 1		#1 = not flipped, -1 = flipped
var all_waypoints_collected = false
var mouse_present = false

func _ready():
	#connect signals
	GlobalSignalManager.connect("flip_world", self, "_on_flip_world")
	GlobalSignalManager.connect("dig_tile", self, "_on_dig_tile")
	GlobalSignalManager.connect("despawn_player", self, "spawn")
	GlobalSignalManager.connect("all_waypoints_collected", self, "_on_all_waypoints_collected")
	
	init_position = global_position
	init_gravity = gravity
	init_dig_count = dig_count
	
	$PlayerSprite.modulate = color_player
	$CPUParticles2D.color = color_player
	$PauseLabel.modulate = Color8(255,255,255,0)
	spawn(GlobalVariableManager.DESPAWN_CONDITIONS.Init)
	dig_count_check()


func spawn(despawn_condition):
	self.flipped = 1
	set_collision_layer_bit(0, false)
	set_collision_mask_bit(0, false)
	global_position = init_position
	$PlayerSprite.scale = Vector2(0,0)
	$CPUParticles2D.scale = Vector2(0,0)
	gravity = 0
	velocity = Vector2.ZERO
	$CPUParticles2D.emitting = true
	dig_count = init_dig_count
	
	var tween_duration = .5
	var tween_delay = 1.0
	
	$Tween.interpolate_property($PlayerSprite, "scale", $PlayerSprite.scale, Vector2(1,1),
	tween_duration, Tween.TRANS_BACK, Tween.EASE_OUT, tween_delay
	)
	$Tween.interpolate_property($PlayerSprite, "rotation_degrees", -360, 0,
	tween_duration, Tween.TRANS_BACK, Tween.EASE_OUT, tween_delay
	)
	$Tween.interpolate_property($CPUParticles2D, "scale", $CPUParticles2D.scale, Vector2(1,1),
	tween_duration, Tween.TRANS_BACK, Tween.EASE_OUT, tween_delay
	)

	$Tween.start()
	
	yield($Tween, "tween_all_completed")
	$CPUParticles2D.emitting = false
	set_collision_layer_bit(0, true)
	set_collision_mask_bit(0, true)
	gravity = init_gravity


func despawn(despawn_condition):
	$PlayerSprite.scale = Vector2(1,1)
	gravity = 0
	velocity = Vector2.ZERO
	
	var tween_duration = .25
	var tween_transition = Tween.TRANS_CIRC
	var tween_ease = Tween.EASE_IN
	var tween_delay = 0.0
	
	$Tween.interpolate_property($PlayerSprite, "scale", $PlayerSprite.scale, Vector2(0,0),
	tween_duration, tween_transition, tween_ease, tween_delay
	)
	$Tween.interpolate_property($PlayerSprite, "rotation_degrees", 0, -360,
	tween_duration, tween_transition, tween_ease, tween_delay
	)

	$Tween.start()
	
	yield($Tween, "tween_all_completed")
	gravity = init_gravity
	
	GlobalSignalManager.emit_signal("despawn_player", despawn_condition)


func _on_all_waypoints_collected():
	all_waypoints_collected = true


func _process(delta):
	GlobalVariableManager.player_position = global_position
	GlobalVariableManager.player_dig_count = dig_count
	$CPUParticles2D.global_position = init_position
	
	$DigCountLabel.rect_rotation = $PlayerSprite.rotation_degrees
	$DigCountLabel.rect_scale = $PlayerSprite.scale
	$DigCountLabel.text = str(dig_count).pad_zeros(2)


func _on_flip_world(flip_tile_pos):
	yield(get_tree(), "physics_frame")
	
	flipped *= -1
	var previous_pos = global_position
	
	$Tween.interpolate_property(self, "global_position", global_position, flip_tile_pos, 
	GlobalVariableManager.tween_duration, 
	GlobalVariableManager.tween_transition, 
	GlobalVariableManager.tween_easing)
	
	$Tween.interpolate_property($Camera2D, "zoom:y", $Camera2D.zoom.y, -$Camera2D.zoom.y, 
	GlobalVariableManager.tween_duration, 
	GlobalVariableManager.tween_transition, 
	GlobalVariableManager.tween_easing)
	
	$Tween.interpolate_property($Camera2D, "limit_top", $Camera2D.limit_top, $Camera2D.limit_bottom, 
	GlobalVariableManager.tween_duration, 
	GlobalVariableManager.tween_transition, 
	GlobalVariableManager.tween_easing)

	$Tween.interpolate_property($Camera2D, "limit_bottom", $Camera2D.limit_bottom, $Camera2D.limit_top, 
	GlobalVariableManager.tween_duration, 
	GlobalVariableManager.tween_transition, 
	GlobalVariableManager.tween_easing)
	
	$Tween.start()
	yield($Tween, "tween_all_completed")
	velocity = velocity_transition.rotated(previous_pos.angle_to_point(flip_tile_pos))


func _on_dig_tile():
	dig_count -= 1
	dig_count_check()



func dig_count_check():
	$DigCountLabel.visible = dig_count > 0


func _physics_process(delta):
	get_input()
	move_and_slide(velocity * delta, Vector2.UP)


func get_input():
	if not $Tween.is_active():
		#if mouse is not present, return to non-paused state
		if (velocity != Vector2(0,0)) and !mouse_in_area(get_global_mouse_position()):
			_on_Area2D_mouse_exited()
		
		if Input.is_action_pressed("move_left"):		#move to the left
			velocity.x = clamp(velocity.x - haccel, -velocity_max.x, velocity_max.x)
		elif Input.is_action_pressed("move_right"):		#move to the right
			velocity.x = clamp(velocity.x + haccel, -velocity_max.x, velocity_max.x)
		else:											#come to rest
			if velocity.x > hdecel:
				velocity.x = clamp(velocity.x - hdecel, -velocity_max.x, velocity_max.x)
			elif velocity.x < -hdecel:
				velocity.x = clamp(velocity.x + hdecel, -velocity_max.x, velocity_max.x)
			else:
				velocity.x = 0
				
				if velocity.y == 0:
					#snap player to grid if close to cell position
					var global_position_map = $PlayerTileMap.map_to_world($PlayerTileMap.world_to_map(global_position))
					var min_distance_to_snap = 16
					if abs(global_position.x - global_position_map.x - 32) < min_distance_to_snap:
						global_position.x = global_position_map.x + 32
		
		if (is_on_floor() and flipped == 1) or (is_on_ceiling() and flipped == -1):
			if Input.is_action_pressed("move_up") and not jump_flag:
				velocity.y = clamp(-jump * flipped, -velocity_max.y, velocity_max.y)
				jump_flag = true
			else:
				velocity.y = 0
		else:
			#apply gravity
			velocity.y = clamp(velocity.y + gravity * flipped, -velocity_max.y, velocity_max.y)
		
		if jump_flag and $JumpTimer.is_stopped():
			$JumpTimer.start()
		
		if Input.is_action_just_released("move_up"):
			if velocity.y < 0 and flipped == 1:
				velocity.y = velocity.y / clamp($JumpTimer.time_left, 1, $JumpTimer.wait_time)
			if velocity.y > 0 and flipped == -1:
				velocity.y = velocity.y / clamp($JumpTimer.time_left, 1, $JumpTimer.wait_time)
			
			$JumpTimer.stop()
		
		if (is_on_ceiling() and flipped == 1) or (is_on_floor() and flipped == -1):
			velocity.y = gravity * flipped
		
		if is_on_wall():
			velocity.x = -velocity.normalized().x

		
		#reset jump flag
		if not Input.is_action_pressed("move_up"):
			jump_flag = false
		
	if Input.is_action_just_released("restart_level"):
		get_tree().reload_current_scene()
	
	if Input.is_action_just_pressed("mouse_left_click") and mouse_present:
		print(mouse_present)
		GlobalSignalManager.emit_signal("pause_scene")


func mouse_in_area(mouse_pos):
	return mouse_pos.x > global_position.x - 32 and mouse_pos.x < global_position.x + 32 and mouse_pos.y > global_position.y - 32 and mouse_pos.y < global_position.y + 32



func _on_Area2D_body_entered(body):
	if body.is_in_group("tile"):
		if body.tile_state == GlobalVariableManager.TILE_STATES.Bad:
			despawn(GlobalVariableManager.DESPAWN_CONDITIONS.Bad)
		if body.tile_state == GlobalVariableManager.TILE_STATES.Good and all_waypoints_collected:
			despawn(GlobalVariableManager.DESPAWN_CONDITIONS.Good)


func _on_Area2D_mouse_entered():
	if velocity == Vector2(0,0):
		mouse_present = true
		$PauseTween.stop_all()
		var tween_duration = .5
		var tween_transition = Tween.TRANS_QUINT
		var tween_easing = Tween.EASE_OUT
		
		$PauseTween.interpolate_property($PlayerSprite, "scale", $PlayerSprite.scale, Vector2(1.5,1.5), 
		tween_duration, tween_transition, tween_easing)
		
		$PauseTween.interpolate_property($PlayerSprite, "modulate", $PlayerSprite.modulate, color_pause, 
		tween_duration, tween_transition, tween_easing)
		
		$PauseTween.interpolate_property($DigCountLabel, "modulate", $DigCountLabel.modulate, Color8(255,255,255,0), 
		tween_duration, tween_transition, tween_easing)
		
		$PauseTween.interpolate_property($PauseLabel, "modulate", $PauseLabel.modulate, Color8(255,255,255,255), 
		tween_duration, tween_transition, tween_easing)
		
		$PauseTween.start()


func _on_Area2D_mouse_exited():
	mouse_present = false
	$PauseTween.stop_all()
	var tween_duration = .25
	var tween_transition = Tween.TRANS_QUINT
	var tween_easing = Tween.EASE_OUT
	
	$PauseTween.interpolate_property($PlayerSprite, "scale", $PlayerSprite.scale, Vector2(1,1), 
	tween_duration, tween_transition, tween_easing)
	
	$PauseTween.interpolate_property($PlayerSprite, "modulate", $PlayerSprite.modulate, color_player, 
	tween_duration, tween_transition, tween_easing)
	
	$PauseTween.interpolate_property($DigCountLabel, "modulate", $DigCountLabel.modulate, Color8(255,255,255,255), 
	tween_duration, tween_transition, tween_easing)
	
	$PauseTween.interpolate_property($PauseLabel, "modulate", $PauseLabel.modulate, Color8(255,255,255,0), 
	tween_duration, tween_transition, tween_easing)
	
	$PauseTween.start()
