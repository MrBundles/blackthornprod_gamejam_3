extends CanvasLayer

#variables
var active = true
var init_msec = 0
var current_msec = 0
var elapsed_msec = 0
var elapsed_sec = 0
var elapsed_min = 0
export var last_scene = false


func _ready():
	#connect signals
	GlobalSignalManager.connect("despawn_player", self, "_on_despawn_player")
	
	init_msec = OS.get_ticks_msec()


func _on_despawn_player(despawn_condition):
	if despawn_condition == GlobalVariableManager.DESPAWN_CONDITIONS.Good and active:
		GlobalSignalManager.emit_signal("save_time", current_msec - init_msec)
	
	init_msec = OS.get_ticks_msec()


func _process(delta):
	offset = get_parent().global_position
	if not last_scene:
		$VBoxContainer/HBoxContainer2/Title.text = str(GlobalVariableManager.current_level_id).pad_zeros(2)
		$VBoxContainer2/HBoxContainer2/TimerLabel.visible = GlobalVariableManager.speedrun_mode
		
		current_msec = OS.get_ticks_msec()
		elapsed_msec = current_msec - init_msec
		elapsed_sec = elapsed_msec / 1000
		elapsed_msec = elapsed_msec - (elapsed_sec * 1000)
		elapsed_min = elapsed_sec / 60
		elapsed_sec = elapsed_sec - (elapsed_min * 60)
		$VBoxContainer2/HBoxContainer2/TimerLabel.text = str(elapsed_min).pad_zeros(2) + ":" + str(elapsed_sec).pad_zeros(2) + "." + str(elapsed_msec)
