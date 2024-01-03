@tool
extends Label
class_name AutoLabel

func _process(_delta):
	pivot_offset = size / 2
	var p = get_parent()
	scale = Vector2.ONE * minf(1., minf(p.size.x / size.x, p.size.y / size.y))
