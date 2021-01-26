extends KinematicBody2D

#variables
export var color_player = Color8(0,0,0,255)

var velocity = Vector2(0,0)
export var velocity_transition = Vector2(-1000,0)
export var velocity_max = Vector2(5000,5000)
export var haccel = 1000
export var hdecel = 1000
export var jump = 1000
var jump_flag = false
export var gravity = 1000

var flipped = 1		#1 = not flipped, -1 = flipped

func _ready():
	#connect signals
	GlobalSignalManager.connect("flip_world", self, "_on_flip_world")
	
	$PlayerSprite.modulate = color_player
	spawn()


func spawn():
	$PlayerSprite.scale = Vector2(0,0)
	$CPUParticles2D.scale = Vector2(0,0)
	var temp_gravity = gravity
	gravity = 0
	
	var tween_duration = .5
	var tween_delay = 1.0
	
	$Tween.interpolate_property($PlayerSprite, "scale", Vector2(0,0), Vector2(1,1),
	tween_duration, Tween.TRANS_BACK, Tween.EASE_OUT, tween_delay
	)
	$Tween.interpolate_property($PlayerSprite, "rotation_degrees", -360, 0,
	tween_duration, Tween.TRANS_BACK, Tween.EASE_OUT, tween_delay
	)
	$Tween.interpolate_property($CPUParticles2D, "scale", Vector2(0,0), Vector2(1,1),
	tween_duration, Tween.TRANS_BACK, Tween.EASE_OUT, tween_delay
	)
	$Tween.interpolate_property($CPUParticles2D, "lifetime", 1, .15,
	tween_duration, Tween.TRANS_BACK, Tween.EASE_OUT, tween_delay
	)
	
	$Tween.start()
	
	yield($Tween, "tween_all_completed")
	$CPUParticles2D.emitting = false
	gravity = temp_gravity


func _process(delta):
	GlobalVariableManager.player_position = global_position


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


func _physics_process(delta):
	get_input()
	move_and_slide(velocity * delta, Vector2.UP)


func get_input():
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
