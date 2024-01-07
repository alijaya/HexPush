extends Structure
class_name StructureEdge

static var Default = load("res://resource/structure/misc/StructureEdge.tres")

const REQUIREMENTS := &"requirements"

func is_flat():
	return true

func can_pack() -> bool:
	return false

func _step_tick(object: StructureObject):
	var item := Gameplay.I.get_item(object.coordsi)
	var requirements := get_requirements(object)
	if item and requirements.has(item.item):
		Gameplay.I.remove_item(object.coordsi, true)
		requirements.erase(item.item)
	if requirements.is_empty():
		Gameplay.I.exploreMap(object.coordsi)
		#object.delete()
	
func get_requirements(object: StructureObject) -> Array[Item]:
	var result: Array[Item] = []
	result.assign(object.get_data(REQUIREMENTS, []))
	return result

func set_requirements(object: StructureObject, requirements: Array[Item]):
	object.set_data(REQUIREMENTS, requirements)

func can_enter(object: StructureObject, input_dir: Constant.Direction):
	return true

func push_item_to(object: StructureObject, item: ItemObject, input_dir: Constant.Direction) -> bool:
	if !item: return false
	return get_requirements(object).has(item.item)
