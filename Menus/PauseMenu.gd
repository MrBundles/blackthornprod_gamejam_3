extends Control


func _ready():
	#connect signals
	GlobalSignalManager.connect("resume_scene", self, "_on_resume_scene")


func _process(delta):
	$CanvasLayer.offset = rect_global_position
	$CanvasLayer2.offset = rect_global_position
