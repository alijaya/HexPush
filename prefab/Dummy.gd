@tool
extends Node2D
class_name Dummy

@export var width: float = 100:
	set(v):
		width = v
		_update_display()
@export var height: float = 100:
	set(v):
		height = v
		_update_display()
@export var color: Color = Color.WHITE:
	set(v):
		color = v
		_update_display()
@export var text_color: Color = Color.BLACK:
	set(v):
		text_color = v
		_update_display()
@export var text: String = "":
	set(v):
		text = v
		_update_display()
@export var text_size: int = 16:
	set(v):
		text_size = v
		_update_display()

@onready var colorRect: ColorRect = $ColorRect
@onready var label: Label = $ColorRect/Label

func _ready():
	_update_display()

func _update_display():
	if !colorRect or !label: return
	colorRect.size = Vector2(width, height)
	colorRect.position = -colorRect.size / 2
	colorRect.pivot_offset = colorRect.size / 2
	colorRect.color = color
	label.text = text
	label.label_settings.font_size = text_size
	label.label_settings.font_color = text_color
