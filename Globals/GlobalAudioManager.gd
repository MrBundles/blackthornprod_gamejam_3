extends Node


func _ready():
	#connect signals
	GlobalSignalManager.connect("change_bus_mute", self, "_on_change_bus_mute")
	GlobalSignalManager.connect("change_bus_volume", self, "_on_change_bus_volume")


func _on_change_bus_mute(bus_id, new_val):
	AudioServer.set_bus_mute(bus_id, new_val)


func _on_change_bus_volume(bus_id, new_val):
	AudioServer.set_bus_volume_db(bus_id, new_val)
