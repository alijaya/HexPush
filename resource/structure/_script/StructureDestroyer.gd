extends Structure
class_name StructureDestroyer

static var Default = load("res://resource/structure/StructureDestroyer.tres")

func _step_tick(object: StructureObject):
	Gameplay.I.remove_item(object.coordsi, true)

func is_flat():
	return true

func can_enter(object: StructureObject, input_dir: Constant.Direction):
	return true

func get_priority():
	return 1
