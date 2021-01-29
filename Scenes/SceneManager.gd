extends Node2D

#enums
enum TRANSITIONS {Left=-1, Right=1}

#variables
export(Array, PackedScene) var game_scene_array = []
export(Array, PackedScene) var hardcore_game_scene_array = []
export(PackedScene) var menu_level_select
export(PackedScene) var menu_settings
export(PackedScene) var menu_credits
export(PackedScene) var menu_main_menu
export(PackedScene) var menu_pause
export(PackedScene) var menu_empty

var current_level_id = 0
var highest_unlocked_level_id = 1
var hardcore_highest_unlocked_level_id = 1

#rng
var rng = RandomNumberGenerator.new()


func _ready():
	#connect signals
	GlobalSignalManager.connect("to_level_select", self, "_on_to_level_select")
	GlobalSignalManager.connect("to_settings", self, "_on_to_settings")
	GlobalSignalManager.connect("to_credits", self, "_on_to_credits")
	GlobalSignalManager.connect("to_main_menu", self, "_on_to_main_menu")
	GlobalSignalManager.connect("to_quit", self, "_on_to_quit")
	GlobalSignalManager.connect("to_level", self, "_on_to_level")
	GlobalSignalManager.connect("pause_scene", self, "_on_pause_scene")
	GlobalSignalManager.connect("resume_scene", self, "_on_resume_scene")
	GlobalSignalManager.connect("despawn_player", self, "_on_despawn_player")
	GlobalSignalManager.connect("save_time", self, "_on_save_time")
	GlobalSignalManager.connect("toggle_hardcore_mode", self, "_on_toggle_hardcore_mode")
	GlobalSignalManager.connect("toggle_practice_mode", self, "_on_toggle_practice_mode")
	
	#initialize speedrun time arrays
	for i in range(game_scene_array.size()):
		GlobalVariableManager.speedrun_times.append([900000])
	GlobalVariableManager.speedrun_times[0][0] = 0
	GlobalVariableManager.speedrun_times[16][0] = 0
	
	for i in range(hardcore_game_scene_array.size()):
		GlobalVariableManager.hardcore_speedrun_times.append([900000])
	GlobalVariableManager.hardcore_speedrun_times[0][0] = 0
	GlobalVariableManager.hardcore_speedrun_times[16][0] = 0


func _process(delta):
	GlobalVariableManager.highest_unlocked_level_id = highest_unlocked_level_id
	GlobalVariableManager.hardcore_highest_unlocked_level_id = hardcore_highest_unlocked_level_id
	GlobalVariableManager.current_level_id = current_level_id
	GlobalVariableManager.menu_scene_transitioning = $MenuSceneTween.is_active()
	GlobalVariableManager.game_scene_transitioning = $GameSceneTween.is_active()
	
	#check for speedrun mode
	if highest_unlocked_level_id >= game_scene_array.size() - 1:
		GlobalVariableManager.speedrun_mode = true
	
	#check for hardcore mode
	if not GlobalVariableManager.hardcore_mode_unlocked and GlobalVariableManager.best_summed_time < 300000:
		GlobalVariableManager.hardcore_mode_unlocked = true


func change_game_scene(level_id:int, transition:int):	
	if level_id < game_scene_array.size():
		current_level_id = level_id
		
		if GlobalVariableManager.hardcore_mode:
			if current_level_id > hardcore_highest_unlocked_level_id:
				hardcore_highest_unlocked_level_id = current_level_id
		else:
			if current_level_id > highest_unlocked_level_id:
				highest_unlocked_level_id = current_level_id
			
		var tween_duration = .75
		var tween_transition = Tween.TRANS_CUBIC
		var tween_easing = Tween.EASE_IN_OUT
		var tween_delay = 0.0
		var onscreen_scene
		var offscreen_scene
		
		var new_game_scene_instance
		if GlobalVariableManager.hardcore_mode:
			new_game_scene_instance = hardcore_game_scene_array[level_id].instance()
		else:
			new_game_scene_instance = game_scene_array[level_id].instance()
			
		new_game_scene_instance.global_position.x = (get_viewport_rect().size.x + 64) * -transition
		$GameScenes.add_child(new_game_scene_instance)
		$GameScenes.move_child(new_game_scene_instance, 1)
		
		onscreen_scene = $GameScenes.get_child(0)
		offscreen_scene = $GameScenes.get_child(1)
		
		$GameSceneTween.interpolate_property(offscreen_scene, "global_position:x", 
		offscreen_scene.global_position.x, 0,
		tween_duration, tween_transition, tween_easing, tween_delay)
		
		$GameSceneTween.interpolate_property(onscreen_scene, "global_position:x", 
		onscreen_scene.global_position.x, (get_viewport_rect().size.x + 64) * transition,
		tween_duration, tween_transition, tween_easing, tween_delay)
		
		$GameSceneTween.start()
		play_game_scene_transition_sound()
		
		yield($GameSceneTween, "tween_all_completed")
		GlobalSignalManager.emit_signal("level_in_place")
		if $GameScenes.get_child(0).has_node("Player"):
			$GameScenes.get_child(0).get_node("Player").queue_free()
		$GameScenes.move_child($GameScenes.get_child(0), $GameScenes.get_child_count())
		$GameScenes.get_child($GameScenes.get_child_count()-1).emit_signal("self_destruct")


func change_menu_scene(new_menu_scene:PackedScene, transition:int):	
	var tween_duration = .75
	var tween_transition = Tween.TRANS_BACK
	var tween_easing = Tween.EASE_OUT
	var tween_delay = 0.0
	var onscreen_scene
	var offscreen_scene
	
	var new_menu_scene_instance = new_menu_scene.instance()
	new_menu_scene_instance.rect_position.x = get_viewport_rect().size.x * -transition
	$MenuScenes.add_child(new_menu_scene_instance)
	
	onscreen_scene = $MenuScenes.get_child(0)
	offscreen_scene = $MenuScenes.get_child(1)
	
	$MenuSceneTween.interpolate_property(offscreen_scene, "rect_position:x", 
	offscreen_scene.rect_position.x, 0,
	tween_duration, tween_transition, tween_easing, tween_delay)
	
	$MenuSceneTween.interpolate_property(onscreen_scene, "rect_position:x", 
	onscreen_scene.rect_position.x, get_viewport_rect().size.x * transition,
	tween_duration, tween_transition, tween_easing, tween_delay)
	
	$MenuSceneTween.start()
	play_menu_scene_transition_sound()
	
	yield($MenuSceneTween, "tween_all_completed")
	$MenuScenes.get_child(0).queue_free()



func play_game_scene_transition_sound():
	var pitch_scale_range = .2
	
	rng.randomize()
	$GameSceneTransition.pitch_scale = 1 + rng.randf_range(-pitch_scale_range,pitch_scale_range)
	$GameSceneTransition.play()


func play_menu_scene_transition_sound():
	var pitch_scale_range = .2
	
	rng.randomize()
	$MenuSceneTransition.pitch_scale = 1 + rng.randf_range(-pitch_scale_range,pitch_scale_range)
	$MenuSceneTransition.play()


func _on_to_level_select():
	change_menu_scene(menu_level_select, TRANSITIONS.Left)


func _on_to_settings():
	change_menu_scene(menu_settings, TRANSITIONS.Left)


func _on_to_credits():
	change_menu_scene(menu_credits, TRANSITIONS.Left)


func _on_to_main_menu():
	get_tree().paused = false
	change_menu_scene(menu_main_menu, TRANSITIONS.Right)
	change_game_scene(0, TRANSITIONS.Right)


func _on_to_quit():
	get_tree().quit()


func _on_to_level(level_id):
	yield(change_menu_scene(menu_empty, TRANSITIONS.Right), "completed")
	change_game_scene(level_id, TRANSITIONS.Right)


func _on_pause_scene():
	get_tree().paused = true
	change_menu_scene(menu_pause, TRANSITIONS.Left)


func _on_resume_scene():
	get_tree().paused = false
	change_menu_scene(menu_empty, TRANSITIONS.Right)


func _on_despawn_player(despawn_condition):
	if despawn_condition == GlobalVariableManager.DESPAWN_CONDITIONS.Good:
		rng.randomize()
		var rand = rng.randi_range(0,1)
		if rand == 1:
			change_game_scene(current_level_id + 1, TRANSITIONS.Left)
		else:
			change_game_scene(current_level_id + 1, TRANSITIONS.Right)


func _on_save_time(elapsed_msec):
	if GlobalVariableManager.hardcore_mode:
		GlobalVariableManager.hardcore_speedrun_times[current_level_id-1].append(elapsed_msec)
		GlobalVariableManager.hardcore_speedrun_times[current_level_id-1].sort()
	else:
		GlobalVariableManager.speedrun_times[current_level_id-1].append(elapsed_msec)
		GlobalVariableManager.speedrun_times[current_level_id-1].sort()


func _on_toggle_hardcore_mode():
	GlobalVariableManager.hardcore_mode = !GlobalVariableManager.hardcore_mode
	

func _on_toggle_practice_mode():
	GlobalVariableManager.practice_mode = !GlobalVariableManager.practice_mode
	if not GlobalVariableManager.practice_mode_used_once:
		GlobalVariableManager.practice_mode_used_once = true
	
