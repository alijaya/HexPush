@tool
extends Node2D
class_name DummyHex

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
@export_flags("SE", "NE", "N", "NW", "SW", "S") var direction_flags: int = 0:
	set(v):
		direction_flags = v
		_update_display()

@onready var colorPolygon: Polygon2D = $DirectionGroup/PolygonColor
@onready var bound: Control = $Bound
@onready var label: Label = $Bound/Label
@onready var directionGroup: Node2D = $DirectionGroup
@onready var seDir: Polygon2D = $DirectionGroup/SE
@onready var neDir: Polygon2D = $DirectionGroup/NE
@onready var nDir: Polygon2D = $DirectionGroup/N
@onready var nwDir: Polygon2D = $DirectionGroup/NW
@onready var swDir: Polygon2D = $DirectionGroup/SW
@onready var sDir: Polygon2D = $DirectionGroup/S

func _ready():
	label.label_settings = label.label_settings.duplicate()
	_update_display()

func _update_display():
	if !bound: return
	bound.size = Vector2(width, height * sqrt(3)/2)
	bound.position = -bound.size / 2
	bound.pivot_offset = bound.size / 2
	directionGroup.scale = Vector2(width / 100, height / 100)
	
	colorPolygon.color = color
	label.text = text
	label.label_settings.font_size = text_size
	label.label_settings.font_color = text_color
	
	seDir.visible = Util.get_flag(direction_flags, 0)
	neDir.visible = Util.get_flag(direction_flags, 1)
	nDir.visible = Util.get_flag(direction_flags, 2)
	nwDir.visible = Util.get_flag(direction_flags, 3)
	swDir.visible = Util.get_flag(direction_flags, 4)
	sDir.visible = Util.get_flag(direction_flags, 5)
	seDir.color = text_color
	neDir.color = text_color
	nDir.color = text_color
	nwDir.color = text_color
	swDir.color = text_color
	sDir.color = text_color
