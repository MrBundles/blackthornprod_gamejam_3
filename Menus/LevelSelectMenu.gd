extends Control


func _process(delta):
	$VBoxContainer/VBoxContainer/Label2.visible = GlobalVariableManager.speedrun_mode
	
	if GlobalVariableManager.speedrun_mode:
		var elapsed_msec_sum = 0
		for i in range(GlobalVariableManager.speedrun_times.size() - 1):
			elapsed_msec_sum += GlobalVariableManager.speedrun_times[i][0]
		
		var elapsed_sec = elapsed_msec_sum / 1000
		elapsed_msec_sum = elapsed_msec_sum - (elapsed_sec * 1000)
		var elapsed_min = elapsed_sec / 60
		elapsed_sec = elapsed_sec - (elapsed_min * 60)
		$VBoxContainer/VBoxContainer/Label2.text = "Sum of Best Times: " + str(elapsed_min).pad_zeros(2) + ":" + str(elapsed_sec).pad_zeros(2) + "." + str(elapsed_msec_sum)
