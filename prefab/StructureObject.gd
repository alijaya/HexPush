extends Node2D
class_name StructureObject

@export var structure: Structure

@export var coords: Vector2i = Vector2i.ZERO
@export var dir: Constant.Direction = Constant.Direction.S
var hex: Vector3i:
	get:
		return Coords.coords_to_hex(coords)

@onready var dummy: DummyHex = $DummyHex

func _ready():
	if structure: structure._ready(self)

func _process(delta: float):
	if structure: structure._process(self, delta)

func rotateCCW():
	dir = posmod(dir+1, 6)

func rotateCW():
	dir = posmod(dir-1, 6)
