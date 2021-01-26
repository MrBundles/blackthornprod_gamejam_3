extends Node2D

#variables
var waypoint_count = 0


func _ready():
	#connect signals
	GlobalSignalManager.connect("waypoint_collected", self, "_on_waypoint_collected")
	
	waypoint_count = get_child_count()
	waypoint_check()


func _on_waypoint_collected():
	waypoint_count -= 1
	waypoint_check()


func waypoint_check():
	if waypoint_count < 1:
		GlobalSignalManager.emit_signal("all_waypoints_collected")
