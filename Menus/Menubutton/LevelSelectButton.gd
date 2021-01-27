tool
extends MyMenuButton

#variables
export var level_id = 0 setget set_level_id


func _ready():
	self.level_id = level_id


func set_level_id(new_val):
	level_id = new_val
	
	text = str(level_id).pad_zeros(2)


func _on_MenuButton_pressed():
	GlobalSignalManager.emit_signal(signal_name, level_id)
