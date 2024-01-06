extends Resource
class_name Structure

@export var texture: Texture2D
@export var name: String = ""
@export var color: Color = Color.WHITE

static var structurePrefab = load("res://prefab/StructureObject.tscn")
static var infoStructurePrefab = load("res://prefab/info_panel/InfoStructure.tscn")


func create_object() -> StructureObject:
	var object: StructureObject = structurePrefab.instantiate()
	object.structure = self
	return object

func create_info(object: StructureObject) -> InfoStructure:
	var info: InfoStructure = infoStructurePrefab.instantiate()
	info.structure = object
	return info

func is_flat() -> bool:
	return false

func get_priority() -> int:
	return 0

func can_pack() -> bool:
	return true

func can_accept_multiple() -> bool:
	return false

func _ready(object: StructureObject):
	pass

func _step_tick(object: StructureObject):
	pass

func _process(object: StructureObject, delta: float):
	pass

func _on_left_click(object: StructureObject):
	pass

func _on_left_hold(object: StructureObject):
	pass

func _on_right_click(object: StructureObject):
	pass

func _on_right_hold(object: StructureObject):
	pass

func _update_view(object: StructureObject):
	object.z_index = 0 if !is_flat() else -1
	object.dummy.visible = true
	if texture:
		object.sprite.visible = true
		object.sprite.texture = texture
		object.dummy.text = ""
		object.dummy.color = Color.TRANSPARENT
		object.dummy.text_color = color
	else:
		object.dummy.text = name
		object.dummy.color = color
		object.dummy.text_color = Color.BLACK
		object.sprite.visible = false

func _on_item_enter(object: StructureObject, item: ItemObject, input_dir: Constant.Direction):
	pass

func _on_item_exit(object: StructureObject, item: ItemObject, output_dir: Constant.Direction):
	pass

func push_item_to(object: StructureObject, item: ItemObject, input_dir: Constant.Direction) -> bool:
	return false

func can_enter(object: StructureObject, input_dir: Constant.Direction) -> bool:
	return false

func equals(other: Structure) -> bool:
	return self == other
