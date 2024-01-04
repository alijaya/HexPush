extends Resource
class_name Structure

@export var name: String = ""
@export var color: Color = Color.WHITE

const structurePrefab := preload("res://prefab/StructureObject.tscn")

func create_object() -> StructureObject:
	var object: StructureObject = structurePrefab.instantiate()
	object.structure = self
	return object

func _ready(object: StructureObject):
	pass

func _step_tick(object: StructureObject):
	pass

func _process(object: StructureObject, delta: float):
	pass

func _update_view(object: StructureObject):
	object.dummy.text = name
	object.dummy.color = color

func can_enter(dir: Constant.Direction):
	return false

func equals(other: Structure) -> bool:
	return self == other
