extends Structure
class_name StructureResource

static var Feature:= {
	Constant.Feature.Tree : load("res://resource/structure/resource/StructureTree.tres"),
	Constant.Feature.Rock : load("res://resource/structure/resource/StructureRock.tres"),
	Constant.Feature.CoalNode : load("res://resource/structure/resource/StructureCoalNode.tres"),
	Constant.Feature.IronNode : load("res://resource/structure/resource/StructureIronNode.tres"),
}

static var infoStructureResourcePrefab := load("res://prefab/info_panel/InfoStructureResource.tscn")

@export var output: Item
@export var hardness: int = 1
@export var richness: int = 6

const WORK := &"work"
const COUNT := &"count"

func _ready(object: StructureObject):
	set_work(object, 0)
	set_count(object, richness)

func get_info_prefab(object: StructureObject) -> PackedScene:
	return infoStructureResourcePrefab

func get_work(object: StructureObject) -> int:
	return object.get_data(WORK, 0)

func set_work(object: StructureObject, work_count: int):
	object.set_data(WORK, work_count)

func get_count(object: StructureObject) -> int:
	return object.get_data(COUNT, richness)

func set_count(object: StructureObject, count: int):
	object.set_data(COUNT, count)

func can_pack() -> bool:
	return false

func work(object: StructureObject, on_trigger: Callable) -> bool:
	var work_count := get_work(object)
	var count := get_count(object)
	work_count += 1
	if work_count < hardness:
		set_work(object, work_count)
		return true
	
	if !on_trigger.call(): return false
	
	set_work(object, 0)
	count -= 1
	
	if count > 0:
		set_count(object, count)
		return true
	
	object.delete(true)
	return true

func _on_left_click(object: StructureObject):
	work(object, func (): return spawn(object))

func _on_left_hold(object: StructureObject):
	pass

func _on_right_click(object: StructureObject):
	pass

func _on_right_hold(object: StructureObject):
	pass

func spawn(object: StructureObject) -> bool:
	var success := false
	var output_coords := Coords.coords_ring(object.coordsi, 1)
	output_coords.shuffle()
	for coords in output_coords:
		if Gameplay.I.can_add_item(coords) and Gameplay.I.add_item(coords, output, true):
			success = true
			break
	return success
