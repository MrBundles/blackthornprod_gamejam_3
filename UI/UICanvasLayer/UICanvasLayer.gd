extends CanvasLayer


func _process(delta):
	$VBoxContainer/HBoxContainer2/Title.text = str(GlobalVariableManager.current_level_id).pad_zeros(2)
