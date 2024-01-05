extends Structure
class_name StructureGenerator

static var WoodGenerator = load("res://resource/structure/StructureWoodGenerator.tres")
static var StoneGenerator = load("res://resource/structure/StructureStoneGenerator.tres")

@export var output: Item
@export var tick: int = 1

func _update_view(object: StructureObject):
	super(object)
	object.dummy.direction_flags = 1 << object.dir

func _step_tick(object: StructureObject):
	if Gameplay.I.push_item_from(object.coordsi, object.dir):
		object.priority = 0
		Gameplay.I.add_item(object.coordsi, output, true)
	else:
		object.priority += 1
