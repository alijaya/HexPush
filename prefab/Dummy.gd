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
@export_flags("Up", "Right", "Down", "Left") var direction_flags: int = 0:
	set(v):
		direction_flags = v
		_update_display()

@onready var colorRect: ColorRect = $ColorRect
@onready var label: Label = $ColorRect/Label
@onready var directionGroup: Node2D = $DirectionGroup
@onready var upDir: Polygon2D = $DirectionGroup/Up
@onready var rightDir: Polygon2D = $DirectionGroup/Right
@onready var downDir: Polygon2D = $DirectionGroup/Down
@onready var leftDir: Polygon2D = $DirectionGroup/Left

func _ready():
	_update_display()

func _update_display():
	if !colorRect: return
	colorRect.size = Vector2(width, height)
	colorRect.position = -colorRect.size / 2
	colorRect.pivot_offset = colorRect.size / 2
	colorRect.color = color
	label.text = text
	label.label_settings.font_size = text_size
	label.label_settings.font_color = text_color
	
	directionGroup.scale = Vector2(width / 100, height / 100)
	upDir.visible = Util.get_flag(direction_flags, 0)
	rightDir.visible = Util.get_flag(direction_flags, 1)
	downDir.visible = Util.get_flag(direction_flags, 2)
	leftDir.visible = Util.get_flag(direction_flags, 3)
	upDir.color = text_color
	rightDir.color = text_color
	downDir.color = text_color
	leftDir.color = text_color
