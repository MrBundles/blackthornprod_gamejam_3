extends CanvasLayer


func _ready():
	#connect signals
	GlobalSignalManager.connect("update_label", self, "_on_update_label")


func _on_update_label(velocity):
	$Label.text = "Velocity: " + str(velocity)
