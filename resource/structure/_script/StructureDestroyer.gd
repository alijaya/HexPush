extends Structure
class_name StructureDestroyer

static var Default = load("res://resource/structure/StructureDestroyer.tres")

func is_flat():
	return true

func _step_tick(object: StructureObject):
	Gameplay.I.remove_item(object.coordsi, true)

func can_enter(object: StructureObject, input_dir: Constant.Direction):
	return true

func push_item_to(object: StructureObject, item: ItemObject, input_dir: Constant.Direction) -> bool:
	return Gameplay.I.get_item(object.coordsi) == null

func get_priority():
	return 1
