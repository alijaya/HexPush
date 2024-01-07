extends Structure
class_name StructureSplitter

static var Splitter1Way = load("res://resource/structure/logistic/StructureSplitter1Way.tres")
static var Splitter2Way = load("res://resource/structure/logistic/StructureSplitter2Way.tres")
static var Splitter3Way = load("res://resource/structure/logistic/StructureSplitter3Way.tres")

@export_flags("Front", "Front Left", "Back Left", "Back", "Back Right", "Front Right") var outputs: int = 0
@export var textures: Array[Texture2D] = []

const OUTPUT_INDEX := &"output_index"

func get_texture(object: StructureObject) -> Texture2D:
	if textures.is_empty(): return null
	else: return textures[posmod(object.dir, textures.size())]

func get_output_index(object: StructureObject) -> int:
	return object.get_data(OUTPUT_INDEX, 0)

func set_output_index(object: StructureObject, output_index: int):
	object.set_data(OUTPUT_INDEX, output_index)
	
func get_output_dirs(object: StructureObject, offset: int = 0) -> Array[Constant.Direction]:
	var result: Array[Constant.Direction] = []
	for i in range(6):
		if Util.get_flag(outputs, i): result.append(posmod(object.dir + i, 6) as Constant.Direction)
	var result_offset: Array[Constant.Direction] = []
	for i in range(result.size()):
		result_offset.append(result[posmod(i+offset, result.size())])
	return result_offset

func get_output_count() -> int:
	var result := 0
	for i in range(6):
		if Util.get_flag(outputs, i): result += 1
	return result

func _ready(object: StructureObject):
	set_output_index(object, get_output_count() - 1)

func _update_view(object: StructureObject):
	super(object)
	object.dummy.direction_flags = get_output_dirs(object).reduce(func (acc, v): return acc | 1 << v, 0)

func _on_item_exit(object: StructureObject, item: ItemObject, output_dir: Constant.Direction):
	var last_index: int = get_output_index(object)
	var output_dirs := get_output_dirs(object)
	for i in range(output_dirs.size()):
		if output_dirs[i] == output_dir:
			last_index = i
			break
	set_output_index(object, last_index)

func is_flat():
	return true

func push_item_to(object: StructureObject, item: ItemObject, input_dir: Constant.Direction) -> bool:
	if !can_enter(object, input_dir): return false
	
	var output_index = get_output_index(object) + 1
	var output_dirs := get_output_dirs(object, output_index)
	for try_dir in output_dirs:
		var nex_coords := Coords.coords_neighbor(object.coordsi, try_dir)
		if Gameplay.I.push_item_to(null, nex_coords, try_dir):
			Gameplay.I.push_item_from(object.coordsi, try_dir)
			return true
	
	# try pop bubble
	if Gameplay.I.push_item_from(object.coordsi, output_dirs[0]): return true
	return false

func can_enter(object: StructureObject, input_dir: Constant.Direction):
	return get_output_dirs(object).all(func (v): return input_dir != posmod(v + 3, 6))
