extends Resource
class_name Structure

@export var name: String = ""
@export var color: Color = Color.WHITE

func _ready(object):
	var structureObject := object as StructureObject
	structureObject.dummy.text = name
	structureObject.dummy.color = color
	pass

func _process(object, delta: float):
	var structureObject := object as StructureObject
	pass

func can_enter(dir: Constant.Direction):
	return false

func equals(other) -> bool:
	return self == other
