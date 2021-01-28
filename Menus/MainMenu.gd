extends Control


func _process(delta):
	$SpeedrunLabel.visible = GlobalVariableManager.speedrun_mode
