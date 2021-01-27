extends Node2D

#enums
enum TRANSITIONS {Left=-1, Right=1}

#variables
export(Array, PackedScene) var game_scene_array = []
export(PackedScene) var menu_level_select
export(PackedScene) var menu_settings
export(PackedScene) var menu_credits
export(PackedScene) var menu_main_menu

var current_level_id = 0


func _ready():
	#connect signals
	GlobalSignalManager.connect("to_level_select", self, "_on_to_level_select")
	GlobalSignalManager.connect("to_settings", self, "_on_to_settings")
	GlobalSignalManager.connect("to_credits", self, "_on_to_credits")
	GlobalSignalManager.connect("to_main_menu", self, "_on_to_main_menu")
	GlobalSignalManager.connect("to_quit", self, "_on_to_quit")
	GlobalSignalManager.connect("to_level", self, "_on_to_level")
	GlobalSignalManager.connect("pause_scene", self, "_on_pause_scene")


func clear_game_scene():
	for child in $GameScenes.get_children():
		child.queue_free()


func clear_menu_scene():
	for child in $MenuScenes.get_children():
		child.queue_free()


func change_game_scene(level_id:int):
	clear_game_scene()
	clear_menu_scene()
	
	var new_game_scene_instance = game_scene_array[level_id].instance()
	$GameScenes.add_child(new_game_scene_instance)


func change_menu_scene(new_menu_scene:PackedScene, transition:int):
	var tween_duration = .5
	var tween_transition = Tween.TRANS_BACK
	var tween_easing = Tween.EASE_OUT
	var tween_delay = 0.0
	var onscreen_scene
	var offscreen_scene
	
	var new_menu_scene_instance = new_menu_scene.instance()
	new_menu_scene_instance.rect_position.x = get_viewport_rect().size.x * -transition
	$MenuScenes.add_child(new_menu_scene_instance)
	
	if $MenuScenes.get_child_count() > 0:
		onscreen_scene = $MenuScenes.get_child(0)
		offscreen_scene = $MenuScenes.get_child(1)
	else:
		offscreen_scene = $MenuScenes.get_child(0)
	
	$Tween.interpolate_property(offscreen_scene, "rect_position:x", 
	$MenuScenes.get_child(1).rect_position.x, 0,
	tween_duration, tween_transition, tween_easing, tween_delay)
	
	if $MenuScenes.get_child_count() > 0:
		$Tween.interpolate_property(onscreen_scene, "rect_position:x", 
		$MenuScenes.get_child(0).rect_position.x, get_viewport_rect().size.x * transition,
		tween_duration, tween_transition, tween_easing, tween_delay)
	
	$Tween.start()
	
	yield($Tween, "tween_all_completed")
	$MenuScenes.get_child(0).queue_free()


func _on_to_level_select():
	change_menu_scene(menu_level_select, TRANSITIONS.Left)


func _on_to_settings():
	change_menu_scene(menu_settings, TRANSITIONS.Left)


func _on_to_credits():
	change_menu_scene(menu_credits, TRANSITIONS.Left)


func _on_to_main_menu():
	change_menu_scene(menu_main_menu, TRANSITIONS.Right)


func _on_to_quit():
	get_tree().quit()


func _on_to_level(level_id):
	change_game_scene(level_id)


func _on_pause_scene():
	print("pause")
	get_tree().paused = true
