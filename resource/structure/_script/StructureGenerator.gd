extends Structure
class_name StructureGenerator

static var Default = load("res://resource/structure/StructureGenerator.tres")

@export var output: Item
@export var tick: int = 1

func _update_view(object: StructureObject):
	super(object)
	object.dummy.direction_flags = 1 << object.dir

func _step_tick(object: StructureObject):
	if Gameplay.I.push_item(object.coordsi, object.dir):
		object.priority = 0
		Gameplay.I.add_item(object.coordsi, output, true)
	else:
		object.priority += 1

func get_output_dir(object: StructureObject, input_dir: Constant.Direction) -> Constant.Direction:
	return object.dir
