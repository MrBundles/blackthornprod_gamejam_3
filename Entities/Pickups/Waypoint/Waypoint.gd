extends Node2D

#variables
export var color = Color8(255,255,255,255) setget set_color
var degrees_start = 0
var degrees_end = 360
var scale_start = Vector2(.5,.5)
var scale_end = Vector2(.75,.75)

#rng
var rng = RandomNumberGenerator.new()


func _ready():
	self.color = color
	init_tween()
	rng.randomize()


func set_color(new_val):
	color = new_val
	
	modulate = color



func init_tween():
	rng.randomize()
	yield(get_tree().create_timer(rng.randf_range(1, 5)), "timeout")
	
	var tween_duration = 3
	var tween_delay = 0.0
	
	$Tween.interpolate_property($Sprites, "rotation_degrees", degrees_start, degrees_end,
	tween_duration, Tween.TRANS_ELASTIC, Tween.EASE_OUT, tween_delay)
	$Tween.interpolate_property($Sprites, "scale", scale_start, scale_end,
	tween_duration, Tween.TRANS_ELASTIC, Tween.EASE_OUT, tween_delay)
	
	$Tween.start()


func _on_Tween_tween_all_completed():
	var swap_dir = rng.randi_range(0,1)
	if swap_dir == 1:
		var degrees_temp = degrees_start
		degrees_start = degrees_end
		degrees_end = degrees_temp
		
	var scale_temp = scale_start
	scale_start = scale_end
	scale_end = scale_temp
	
	init_tween()


func _on_Area2D_area_entered(area):
	if area.is_in_group("player"):
		$Sprites.hide()
		$WaypointParticles.emitting = true
		yield(get_tree().create_timer($WaypointParticles.lifetime), "timeout")
		GlobalSignalManager.emit_signal("waypoint_collected")
		queue_free()
