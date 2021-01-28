extends Node2D

#variables
var waypoint_count = 0
var init_waypoint_count = 0


func _ready():
	#connect signals
	GlobalSignalManager.connect("waypoint_collected", self, "_on_waypoint_collected")
	GlobalSignalManager.connect("despawn_player", self, "_on_despawn_player")
	
	waypoint_count = get_child_count()
	init_waypoint_count = waypoint_count
	waypoint_check()


func _on_waypoint_collected():
	waypoint_count -= 1
	print(init_waypoint_count)
	waypoint_check()


func _on_despawn_player(despawn_condition):
	waypoint_count = init_waypoint_count


func waypoint_check():
	if waypoint_count < 1:
		GlobalSignalManager.emit_signal("all_waypoints_collected")
