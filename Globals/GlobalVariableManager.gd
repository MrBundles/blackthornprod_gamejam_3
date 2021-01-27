extends Node

#enums
enum TILE_STATES {Active, Solid, Inactive, Bad, Good}
enum DESPAWN_CONDITIONS {Init, Bad, Good, Teleport}

#world flip tween values
var tween_duration = .5
var tween_transition = Tween.TRANS_EXPO
var tween_easing = Tween.EASE_IN

var player_position = Vector2(0,0)
var player_dig_count = 0
var dig_count = 0
