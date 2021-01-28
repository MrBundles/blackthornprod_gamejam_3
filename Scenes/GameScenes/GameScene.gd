extends Node2D

#signals
signal self_destruct

#variables
var self_destructing = false


func _on_GameScene_self_destruct():
	self_destructing = true
	var delay = .01
	
	get_node("Waypoints").queue_free()
	
	for child in $LevelTileMap.get_children():
		child.queue_free()
		yield(get_tree().create_timer(delay), "timeout")
	
	for child in get_children():
		child.queue_free()
		yield(get_tree().create_timer(delay), "timeout")
	
	queue_free()
