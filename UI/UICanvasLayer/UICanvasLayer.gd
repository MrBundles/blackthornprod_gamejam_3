extends CanvasLayer

#variables
var active = true
var init_msec = 0
var current_msec = 0
var elapsed_msec = 0
var elapsed_sec = 0
var elapsed_min = 0
export var last_scene = false
var lives_lost = 0
var practice_label_rotation = 1.5

export var normal_color = Color(1,1,1,1)
export var practice_color = Color(1,1,1,1)


func _ready():
	#connect signals
	GlobalSignalManager.connect("despawn_player", self, "_on_despawn_player")
	
	init_msec = OS.get_ticks_msec()
	
	if has_node("PracticeModeReminder"):
		_on_Tween_tween_all_completed()


func _on_despawn_player(despawn_condition):
	if despawn_condition == GlobalVariableManager.DESPAWN_CONDITIONS.Good and active:
		GlobalSignalManager.emit_signal("save_time", current_msec - init_msec)
	if despawn_condition == GlobalVariableManager.DESPAWN_CONDITIONS.Bad and active:
		lives_lost += 1
	
	init_msec = OS.get_ticks_msec()


func _process(delta):
	if has_node("PracticeModeReminder"):
		$PracticeModeReminder.visible = (lives_lost >= 7 and not GlobalVariableManager.practice_mode_used_once) or GlobalVariableManager.practice_mode
		$PracticeModeReminder.rect_pivot_offset = $PracticeModeReminder.rect_size / Vector2(2,2)
	
		if GlobalVariableManager.practice_mode:
			$PracticeModeReminder/HBoxContainer2/PracticeLabel.text = "Practice Mode Enabled"
			$PracticeModeReminder/HBoxContainer2/PracticeLabel.modulate = practice_color
		else:
			$PracticeModeReminder/HBoxContainer2/PracticeLabel.text = "Click on the Player to Enable Practice Mode"
			$PracticeModeReminder/HBoxContainer2/PracticeLabel.modulate = normal_color
	
	offset = get_parent().global_position
	if not last_scene:
		$VBoxContainer/HBoxContainer2/Title.text = str(GlobalVariableManager.current_level_id).pad_zeros(2)
		$VBoxContainer2/HBoxContainer2/TimerLabel.visible = GlobalVariableManager.speedrun_mode
		
		current_msec = OS.get_ticks_msec()
		elapsed_msec = current_msec - init_msec
		elapsed_sec = elapsed_msec / 1000
		elapsed_msec = elapsed_msec - (elapsed_sec * 1000)
		elapsed_min = elapsed_sec / 60
		elapsed_sec = elapsed_sec - (elapsed_min * 60)
		$VBoxContainer2/HBoxContainer2/TimerLabel.text = str(elapsed_min).pad_zeros(2) + ":" + str(elapsed_sec).pad_zeros(2) + "." + str(elapsed_msec)


func _on_Tween_tween_all_completed():
	practice_label_rotation *= -1
	var target_rotation
	
	if GlobalVariableManager.practice_mode:
		target_rotation = 0
	else:
		target_rotation = practice_label_rotation
	
	
	$Tween.interpolate_property($PracticeModeReminder, "rect_rotation", $PracticeModeReminder.rect_rotation, target_rotation,
	1.0, Tween.TRANS_ELASTIC, Tween.EASE_OUT, 1.0)
	$Tween.start()


func _on_PracticeLabel_gui_input(event):
	print(event)
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			GlobalVariableManager.practice_mode_used_once = true
