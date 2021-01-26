extends CanvasLayer


func _ready():
	$TextureRect.texture = get_viewport().get_texture()
