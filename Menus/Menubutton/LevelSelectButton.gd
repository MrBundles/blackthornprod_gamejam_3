extends MyMenuButton

#variables
export var level_id = 0 setget set_level_id
export var hardcore_color_border = Color8(255,255,255,255)


func _ready():	
	self.level_id = level_id
	$ColorRect.modulate = Color(1,1,1,0)


func _process(delta):
	if GlobalVariableManager.hardcore_mode:
		$BorderSprite.modulate = hardcore_color_border
		disabled = GlobalVariableManager.hardcore_highest_unlocked_level_id < level_id
	else:
		$BorderSprite.modulate = color_border
		disabled = GlobalVariableManager.highest_unlocked_level_id < level_id
	
	$ColorRect.visible = GlobalVariableManager.speedrun_mode
	
	if GlobalVariableManager.speedrun_times.size() >= level_id and GlobalVariableManager.speedrun_mode:
		var elapsed_msec
		
		if GlobalVariableManager.hardcore_mode:
			elapsed_msec = GlobalVariableManager.hardcore_speedrun_times[level_id][0]
		else:
			elapsed_msec = GlobalVariableManager.speedrun_times[level_id][0]
			
		var elapsed_sec = elapsed_msec / 1000
		elapsed_msec = elapsed_msec - (elapsed_sec * 1000)
		var elapsed_min = elapsed_sec / 60
		elapsed_sec = elapsed_sec - (elapsed_min * 60)
		$ColorRect/VBoxContainer/TimeLabel.text = str(elapsed_min).pad_zeros(2) + ":" + str(elapsed_sec).pad_zeros(2) + "." + str(elapsed_msec)
	else:
		$ColorRect/VBoxContainer/TimeLabel.text = "99:99.999"

func _on_MenuButton_mouse_entered():
	if not disabled:
		$Tween.interpolate_property($BorderSprite, "scale", $BorderSprite.scale, button_scale_border_grow,
		.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
		$Tween.interpolate_property($ColorRect, "modulate", $ColorRect.modulate, Color(1,1,1,1),
		.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
		$Tween.start()
		$MenuButtonHoverOn.play()


func _on_MenuButton_mouse_exited():
	if not disabled:
		$Tween.interpolate_property($BorderSprite, "scale", $BorderSprite.scale, button_scale_border,
		.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
		$Tween.interpolate_property($ColorRect, "modulate", $ColorRect.modulate, Color(1,1,1,0),
		.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
		$Tween.start()
		$MenuButtonHoverOff.play()


func set_level_id(new_val):
	level_id = new_val
	
	text = str(level_id).pad_zeros(2)


func _on_MenuButton_pressed():
	GlobalSignalManager.emit_signal(signal_name, level_id)
