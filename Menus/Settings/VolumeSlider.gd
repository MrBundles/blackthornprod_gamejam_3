tool
extends HBoxContainer

#variables
export var bus_id = 0
export var label = "Volume" setget set_label
export var color_grabber = Color8(255,255,255,255)
export var audio_sample = false


func _ready():
	$MuteButton.pressed = AudioServer.is_bus_mute(bus_id)
	$VolumeSlider.modulate = color_grabber


func set_label(new_val):
	label = new_val
	
	if has_node("VolumeLabel"):
		$VolumeLabel.text = label


func _on_VolumeSlider_value_changed(value):
	GlobalSignalManager.emit_signal("change_bus_volume", bus_id, value)
	if audio_sample:
		$SamplePlayer.play()


func _on_MuteButton_toggled(button_pressed):
	GlobalSignalManager.emit_signal("change_bus_mute", bus_id, button_pressed)
	
	if button_pressed:
		$MuteButton.text = "Unmute"
	else:
		$MuteButton.text = "Mute"
