extends Control


func _process(delta):
	$SpeedrunLabel.visible = GlobalVariableManager.speedrun_mode
	$HardcoreLabel.visible = GlobalVariableManager.hardcore_mode_unlocked
