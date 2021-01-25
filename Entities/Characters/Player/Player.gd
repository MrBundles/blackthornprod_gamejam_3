extends KinematicBody2D

#variables
var velocity = Vector2(0,0)
export var velocity_max = Vector2(5000,5000)
export var haccel = 1000
export var hdecel = 1000
export var jump = 1000
export var gravity = 1000


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
	
	if Input.is_action_just_pressed("move_up"):
		velocity.y = clamp(-jump, -velocity_max.y, velocity_max.y)
	else:
		#apply gravity
		velocity.y = clamp(velocity.y + gravity, -velocity_max.y, velocity_max.y)
	
