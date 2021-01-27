extends MyMenuButton


func _on_RestartButton_pressed():
	GlobalSignalManager.emit_signal("resume_scene")
	GlobalSignalManager.emit_signal(signal_name, GlobalVariableManager.DESPAWN_CONDITIONS.Restart)
