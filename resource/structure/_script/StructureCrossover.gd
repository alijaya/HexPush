extends Structure
class_name StructureCrossover

static var Default = load("res://resource/structure/StructureCrossover.tres")

const STORAGE := &"storage"
#const LAST_INDEX := &"last_index"

func _update_view(object: StructureObject):
	super(object)
	object.dummy.direction_flags = 63 # full

func is_flat():
	return true

func can_accept_multiple() -> bool:
	return true

func push_item_to(object: StructureObject, item: ItemObject, input_dir: Constant.Direction) -> bool:
	var storage: Dictionary = object.get_meta(STORAGE, {})
	object.set_meta(STORAGE, storage)
	var item_index := posmod(input_dir, 3)
	
	var storage_item: ItemObject = storage.get(item_index)
	var nex_coordsi := Coords.coords_neighbor(object.coordsi, input_dir)
	if Gameplay.I.push_item_to(storage_item, nex_coordsi, input_dir):
		storage[item_index] = item
		return true
	
	return false

func can_enter(object: StructureObject, input_dir: Constant.Direction):
	return true
