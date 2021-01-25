extends KinematicBody2D

#variables
var velocity = Vector2(0,0)
export var velocity_transition = Vector2(-1000,0)
export var velocity_max = Vector2(5000,5000)
export var haccel = 1000
export var hdecel = 1000
export var jump = 1000
var jump_flag = false
export var gravity = 1000


func _ready():
	#connect signals
	GlobalSignalManager.connect("flip_world_confirm", self, "_on_flip_world_confirm")


func _on_flip_world_confirm(flip_tile_pos):
	velocity = Vector2(0,0)
	var previous_pos = global_position
	var tween_duration = .5
	var tween_transition = Tween.TRANS_EXPO
	var tween_easing = Tween.EASE_IN
	
	$Tween.interpolate_property(self, "global_position", global_position, flip_tile_pos, 
	tween_duration, tween_transition, tween_easing)
	
	$Tween.start()
	yield($Tween, "tween_all_completed")
	velocity = velocity_transition.rotated(previous_pos.angle_to_point(flip_tile_pos))


func _process(delta):
	update_highlight_sprite()


func update_highlight_sprite():
	var offset = Vector2(32,32)
	var tile_highlight_pos_map = $PlayerTileMap.world_to_map(global_position - Vector2(64,0).rotated(global_position.angle_to_point(get_global_mouse_position())))
	var tile_highlight_pos_world = $PlayerTileMap.map_to_world(tile_highlight_pos_map)
	$TileHighlightSprite.global_position = tile_highlight_pos_world + offset
	GlobalSignalManager.emit_signal("update_label", $TileHighlightSprite.global_position)

func _physics_process(delta):
	get_input()
	move_and_slide(velocity * delta, Vector2.UP)


func get_input():
	if Input.is_action_pressed("move_left"):
		velocity.x = clamp(velocity.x - haccel, -velocity_max.x, velocity_max.x)
	elif Input.is_action_pressed("move_right"):
		velocity.x = clamp(velocity.x + haccel, -velocity_max.x, velocity_max.x)
	else:
		if velocity.x > hdecel:
			velocity.x = clamp(velocity.x - hdecel, -velocity_max.x, velocity_max.x)
		elif velocity.x < -hdecel:
			velocity.x = clamp(velocity.x + hdecel, -velocity_max.x, velocity_max.x)
		else:
			velocity.x = 0
	
	if is_on_floor():
		if Input.is_action_pressed("move_up") and not jump_flag:
			velocity.y = clamp(-jump, -velocity_max.y, velocity_max.y)
			jump_flag = true
		else:
			velocity.y = 0
	else:
		#apply gravity
		velocity.y = clamp(velocity.y + gravity, -velocity_max.y, velocity_max.y)
	
	if Input.is_action_just_released("move_up"):
		if velocity.y < 0:
			velocity.y = velocity.y / 2
	
	if is_on_ceiling():
		velocity.y = gravity
	
	if is_on_wall():
		velocity.x = -velocity.normalized().x
	
	
	#reset jump flag
	if not Input.is_action_pressed("move_up"):
		jump_flag = false
	
	if Input.is_action_just_pressed("mouse_right_click"):
		GlobalSignalManager.emit_signal("dig_tile_request", $TileHighlightSprite.global_position)
	
	if Input.is_action_just_pressed("mouse_left_click"):
		GlobalSignalManager.emit_signal("flip_world_request", $TileHighlightSprite.global_position)
	
	if Input.is_action_just_released("restart_level"):
		get_tree().reload_current_scene()
