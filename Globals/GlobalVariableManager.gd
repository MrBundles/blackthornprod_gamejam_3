extends Node

#enums
enum TILE_STATES {Active, Solid, Inactive, Bad, Good}
enum DESPAWN_CONDITIONS {Init, Bad, Good, Teleport, Restart}

#world flip tween values
var tween_duration = .5
var tween_transition = Tween.TRANS_EXPO
var tween_easing = Tween.EASE_IN
var menu_scene_transitioning = false
var game_scene_transitioning = false

var player_position = Vector2(0,0)
var player_dig_count = 0
var dig_count = 0
var allow_left_click = true
var allow_right_click = true

var current_level_id
var highest_unlocked_level_id

var speedrun_mode = false
