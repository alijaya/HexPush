extends Structure
class_name StructureCombiner

static var Default = load("res://resource/structure/StructureCombiner.tres")

func _update_view(object: StructureObject):
	super(object)
	object.dummy.direction_flags = 1 << object.dir

func is_flat():
	return true

func can_enter(object: StructureObject, input_dir: Constant.Direction):
	return input_dir != posmod(object.dir + 3, 6)

func get_output_dir(object: StructureObject, input_dir: Constant.Direction) -> Constant.Direction:
	return object.dir
