extends Resource
class_name Structure

@export var texture: Texture2D
@export var name: String = ""
@export var color: Color = Color.WHITE

static var structurePrefab = load("res://prefab/StructureObject.tscn")

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
	object.z_index = 0 if !is_flat() else -1
	if texture:
		object.sprite.visible = true
		object.sprite.texture = texture
		object.dummy.visible = false
	else:
		object.dummy.visible = true
		object.dummy.text = name
		object.dummy.color = color
		object.sprite.visible = false

func _on_item_enter(object: StructureObject, item: ItemObject, input_dir: Constant.Direction):
	pass

func is_flat() -> bool:
	return false

func get_priority() -> int:
	return 0

func can_enter(object: StructureObject, input_dir: Constant.Direction) -> bool:
	return false

func get_output_dir(object: StructureObject, input_dir: Constant.Direction) -> Constant.Direction:
	return Constant.Direction.None

func equals(other: Structure) -> bool:
	return self == other
