extends Structure
class_name StructureCombiner

static var Default = load("res://resource/structure/StructureCombiner.tres")

func _update_view(object: StructureObject):
	super(object)
	object.dummy.direction_flags = 1 << object.dir

func is_flat():
	return true

func push_item_to(object: StructureObject, item: ItemObject, input_dir: Constant.Direction) -> bool:
	if !can_enter(object, input_dir): return false
	return Gameplay.I.push_item_from(object.coordsi, object.dir)

func can_enter(object: StructureObject, input_dir: Constant.Direction):
	return input_dir != posmod(object.dir + 3, 6)
