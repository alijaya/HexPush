extends Structure
class_name StructureCrossover

static var Default = load("res://resource/structure/logistic/StructureCrossover.tres")

const STORAGE := &"storage"

func _update_view(object: StructureObject):
	super(object)
	object.dummy.direction_flags = 63 # full

func is_flat():
	return true

func can_accept_multiple() -> bool:
	return true

func get_storage(object: StructureObject) -> Dictionary:
	var storage = object.get_data(STORAGE)
	if !storage:
		storage = {}
		object.set_data(STORAGE, storage)
	return storage

func _on_item_enter(object: StructureObject, item: ItemObject, input_dir: Constant.Direction):
	var storage: Dictionary = get_storage(object)
	var item_index := posmod(input_dir, 3)
	storage[item_index] = item
	Gameplay.I.set_item(object.coordsi, null)

func push_item_to(object: StructureObject, item: ItemObject, input_dir: Constant.Direction) -> bool:
	var storage: Dictionary = get_storage(object)
	var item_index := posmod(input_dir, 3)
	
	var tile_item := Gameplay.I.get_item(object.coordsi)
	var storage_item: ItemObject = storage.get(item_index)
	var nex_coordsi := Coords.coords_neighbor(object.coordsi, input_dir)
	
	if tile_item and storage_item:
		Gameplay.I.push_item_to(tile_item, nex_coordsi, input_dir)
		return false
	elif tile_item:
		return Gameplay.I.push_item_to(tile_item, nex_coordsi, input_dir)
	elif storage_item:
		return Gameplay.I.push_item_to(storage_item, nex_coordsi, input_dir)
	return true

func can_enter(object: StructureObject, input_dir: Constant.Direction):
	return true

func delete(object: StructureObject, animate: bool = false):
	var storage := get_storage(object)
	for i in storage.keys():
		var item: ItemObject = storage[i]
		if item:
			item.delete(animate)
