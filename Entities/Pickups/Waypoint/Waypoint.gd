extends Node2D

#variables
export var color = Color8(255,255,255,255) setget set_color
var degrees_start = 0
var degrees_end = 360
var scale_start = Vector2(.5,.5)
var scale_end = Vector2(.75,.75)
var collected = false
var tween_delay = 0

#rng
var rng = RandomNumberGenerator.new()


func _ready():
	#connect signals
	GlobalSignalManager.connect("despawn_player", self, "_on_despawn_player")
	
	self.color = color
	init_tween()
	rng.randomize()


func set_color(new_val):
	color = new_val
	
	modulate = color


func _on_despawn_player(despawn_condition):
	print($Sprites.scale)
	print(modulate)
	collected = false
	tween_delay = 0.0
	init_tween()


func init_tween():
	if not collected:
		var tween_duration = 3
		
		$Tween.interpolate_property($Sprites, "rotation_degrees", degrees_start, degrees_end,
		tween_duration, Tween.TRANS_ELASTIC, Tween.EASE_OUT, tween_delay)
		$Tween.interpolate_property($Sprites, "scale", $Sprites.scale, scale_end,
		tween_duration, Tween.TRANS_ELASTIC, Tween.EASE_OUT, tween_delay)
		
		$Tween.start()


func _on_Tween_tween_all_completed():
	if not collected:
		var swap_dir = rng.randi_range(0,1)
		if swap_dir == 1:
			var degrees_temp = degrees_start
			degrees_start = degrees_end
			degrees_end = degrees_temp
			
		var scale_temp = scale_start
		scale_start = scale_end
		scale_end = scale_temp
		
		rng.randomize()
		tween_delay = rng.randf_range(1, 5)
		
		init_tween()


func _on_Area2D_area_entered(area):
	if area.is_in_group("player") and not collected:
		collected = true
		$Sprites.scale = Vector2(0,0)
		$WaypointParticles.emitting = true
		$WaypointPickup.play()
		$Tween.stop_all()
		GlobalSignalManager.emit_signal("waypoint_collected")
