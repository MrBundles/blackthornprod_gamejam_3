tool
extends Button
class_name MyMenuButton


#variables
var button_size = Vector2(64,64) setget set_button_size
var button_scale = Vector2(1,1)
var button_scale_border = Vector2(1,1)
var button_scale_border_grow = Vector2(1,1)
var button_scale_border_click = Vector2(1,1)
var button_position = Vector2(0,0)
export var color_border = Color8(255,255,255,255)
export var border_width =  10
export var border_width_grow = 20
export var border_width_click = 30
export var signal_name = ""



func _ready():
	self.button_size = rect_size
	$BorderSprite.modulate = color_border


func set_button_size(new_val):
	button_size = new_val
	
	button_scale = button_size / Vector2(64,64)
	button_scale_border = Vector2(button_size.x + border_width, button_size.y + border_width) / Vector2(64,64)
	button_scale_border_grow = Vector2(button_size.x + border_width_grow, button_size.y + border_width_grow) / Vector2(64,64)
	button_scale_border_click = Vector2(button_size.x + border_width_click, button_size.y + border_width_click) / Vector2(64,64)
	button_position = button_size / Vector2(2,2)
	
	if has_node("BorderSprite"):
		$BorderSprite.scale = button_scale_border
		$BorderSprite.position = button_position


func _on_MenuButton_mouse_entered():
	if not disabled:
		$Tween.interpolate_property($BorderSprite, "scale", $BorderSprite.scale, button_scale_border_grow,
		.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
		$Tween.start()
		$MenuButtonHoverOn.play()


func _on_MenuButton_mouse_exited():
	if not disabled:
		$Tween.interpolate_property($BorderSprite, "scale", $BorderSprite.scale, button_scale_border,
		.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
		$Tween.start()
		$MenuButtonHoverOff.play()


func _on_MenuButton_button_down():
	$Tween.interpolate_property($BorderSprite, "scale", $BorderSprite.scale, button_scale_border_click,
	.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$Tween.start()
	$MenuButtonClick.play()


func _on_MenuButton_button_up():
	$Tween.interpolate_property($BorderSprite, "scale", $BorderSprite.scale, button_scale_border_grow,
	.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$Tween.start()


func _on_MenuButton_pressed():
	GlobalSignalManager.emit_signal(signal_name)
