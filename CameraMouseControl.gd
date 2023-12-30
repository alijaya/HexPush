extends Camera2D

var boundingRect: Rect2 = Rect2()

var currentZoom := 0.0
var targetZoom := 0.0

export var zoomPower := 4.0
export var zoomSpan := 5.0
export var zoomSpeed := .1

func _process(_delta):
	global_position = get_global_mouse_position()
	currentZoom = lerp(currentZoom, targetZoom, zoomSpeed)
	var z := pow(zoomPower, currentZoom / zoomSpan)
	zoom.x = z
	zoom.y = z
	
	var s := get_tree().get_root().size * z
	var rect = boundingRect.grow_individual(s.x/2, s.y/2, s.x/2, s.y/2)
	limit_left = rect.position.x
	limit_top = rect.position.y
	limit_right = rect.end.x
	limit_bottom = rect.end.y

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_WHEEL_UP: targetZoom = max(-zoomSpan, targetZoom - event.factor)
			if event.button_index == BUTTON_WHEEL_DOWN: targetZoom = min(zoomSpan, targetZoom + event.factor)
