extends Control

#variables
export var color = Color8(255,255,255,255)
export var hardcore_color = Color8(255,255,255,255)


func _process(delta):
	$VBoxContainer/VBoxContainer/Label2.visible = GlobalVariableManager.speedrun_mode
	$VBoxContainer/HBoxContainer2/HardcoreButton.visible = GlobalVariableManager.hardcore_mode_unlocked
	$HardcoreHint.visible = not GlobalVariableManager.hardcore_mode_unlocked and GlobalVariableManager.speedrun_mode
	
	if GlobalVariableManager.hardcore_mode:
		$VBoxContainer/VBoxContainer/Label2.modulate = hardcore_color
	else:
		$VBoxContainer/VBoxContainer/Label2.modulate = color
	
	
	if GlobalVariableManager.speedrun_mode:
		var elapsed_msec_sum = 0
		for i in range(GlobalVariableManager.speedrun_times.size() - 1):
			elapsed_msec_sum += GlobalVariableManager.speedrun_times[i][0]
		GlobalVariableManager.best_summed_time = elapsed_msec_sum
		
		for i in range(GlobalVariableManager.hardcore_speedrun_times.size() - 1):
			elapsed_msec_sum += GlobalVariableManager.hardcore_speedrun_times[i][0]
		GlobalVariableManager.hardcore_best_summed_time = elapsed_msec_sum
		
		if GlobalVariableManager.hardcore_mode:
			elapsed_msec_sum = GlobalVariableManager.hardcore_best_summed_time
		else:
			elapsed_msec_sum = GlobalVariableManager.best_summed_time
		
		var elapsed_sec = elapsed_msec_sum / 1000
		elapsed_msec_sum = elapsed_msec_sum - (elapsed_sec * 1000)
		var elapsed_min = elapsed_sec / 60
		elapsed_sec = elapsed_sec - (elapsed_min * 60)
		
		if GlobalVariableManager.hardcore_mode:
			$VBoxContainer/VBoxContainer/Label2.text = "Sum of Best Hardcore Times: " + str(elapsed_min).pad_zeros(2) + ":" + str(elapsed_sec).pad_zeros(2) + "." + str(elapsed_msec_sum)
		else:
			$VBoxContainer/VBoxContainer/Label2.text = "Sum of Best Times: " + str(elapsed_min).pad_zeros(2) + ":" + str(elapsed_sec).pad_zeros(2) + "." + str(elapsed_msec_sum)
