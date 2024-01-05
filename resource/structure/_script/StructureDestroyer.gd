extends Structure
class_name StructureDestroyer

static var Default = load("res://resource/structure/StructureDestroyer.tres")

func is_flat():
	return true

func push_item_to(object: StructureObject, item: ItemObject, input_dir: Constant.Direction) -> bool:
	Gameplay.I.remove_item(object.coordsi, true)
	return true

func can_enter(object: StructureObject, input_dir: Constant.Direction):
	return true
