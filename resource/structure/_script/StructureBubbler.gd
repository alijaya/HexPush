extends Structure
class_name StructureBubbler

static var Default = load("res://resource/structure/logistic/StructureBubbler.tres")

func _step_tick(object: StructureObject):
	if Gameplay.I.push_item_from(object.coordsi, object.dir):
		object.priority = 0
		Gameplay.I.add_item(object.coordsi, ItemBubble.Default, true)
	else:
		object.priority += 1

func _update_view(object: StructureObject):
	super(object)
	object.dummy.direction_flags = 1 << object.dir

func is_flat():
	return true

func push_item_to(object: StructureObject, item: ItemObject, input_dir: Constant.Direction) -> bool:
	if !can_enter(object, input_dir): return false
	return Gameplay.I.push_item_from(object.coordsi, object.dir)

func can_enter(object: StructureObject, input_dir: Constant.Direction):
	return input_dir == object.dir

func get_priority():
	return -1
