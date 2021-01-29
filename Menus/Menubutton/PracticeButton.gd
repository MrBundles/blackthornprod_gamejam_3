extends MyMenuButton

#variablees
export var practice_color = Color(1,1,1,1)


func _process(delta):
	if GlobalVariableManager.practice_mode:
		$BorderSprite.modulate = practice_color
	else:
		$BorderSprite.modulate = color_border
