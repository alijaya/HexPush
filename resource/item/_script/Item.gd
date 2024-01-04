extends Resource
class_name Item

@export var name: String = ""
@export var color: Color = Color.WHITE

func _ready(object):
	pass

func _process(object, delta: float):
	pass

func equals(other) -> bool:
	return self == other
