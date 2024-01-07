extends Structure
class_name StructureSplitter

static var Default = load("res://resource/structure/logistic/StructureSplitter.tres")

const OUTPUT_INDEX := &"output_index"
const output_dirs: Array[int] = [0, 1, -1]

func get_output_index(object: StructureObject) -> int:
	return object.get_data(OUTPUT_INDEX, 0)

func set_output_index(object: StructureObject, output_index: int):
	object.set_data(OUTPUT_INDEX, output_index)

func _ready(object: StructureObject):
	set_output_index(object, output_dirs.size() - 1)

func _update_view(object: StructureObject):
	super(object)
	object.dummy.direction_flags = output_dirs.reduce(func (acc, v): return acc | 1 << posmod(object.dir+v, 6), 0)

func _on_item_exit(object: StructureObject, item: ItemObject, output_dir: Constant.Direction):
	var last_index: int = get_output_index(object)
	for i in range(output_dirs.size()):
		if posmod(object.dir + output_dirs[i], 6) == output_dir:
			last_index = i
			break
	set_output_index(object, posmod(last_index, output_dirs.size()))

func is_flat():
	return true

func push_item_to(object: StructureObject, item: ItemObject, input_dir: Constant.Direction) -> bool:
	if !can_enter(object, input_dir): return false
	
	var output_index = get_output_index(object) + 1
	for i in output_dirs.size():
		var try_dir := posmod(object.dir + output_dirs[posmod(i + output_index, output_dirs.size())], 6) as Constant.Direction
		var nex_coords := Coords.coords_neighbor(object.coordsi, try_dir)
		if Gameplay.I.push_item_to(null, nex_coords, try_dir):
			Gameplay.I.push_item_from(object.coordsi, try_dir)
			return true
	
	# try pop bubble
	if Gameplay.I.push_item_from(object.coordsi, input_dir): return true
	return false

func can_enter(object: StructureObject, input_dir: Constant.Direction):
	return output_dirs.all(func (v): return input_dir != posmod(object.dir+v + 3, 6))
