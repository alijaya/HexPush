extends Structure
class_name StructureResource

static var Feature:= {
	Constant.Feature.Tree : load("res://resource/structure/StructureTree.tres"),
	Constant.Feature.Rock : load("res://resource/structure/StructureRock.tres"),
}

@export var output: Item
@export var hardness: int = 1
@export var richness: int = 6

const WORK := &"work"
const COUNT := &"count"

func _ready(object: StructureObject):
	object.set_meta(WORK, 0)
	object.set_meta(COUNT, richness)
	
func can_pack() -> bool:
	return false

func work(object: StructureObject, on_trigger: Callable):
	var work_count: int = object.get_meta(WORK, 0)
	var count: int = object.get_meta(COUNT, richness)
	work_count += 1
	if work_count < hardness:
		object.set_meta(WORK, work_count)
		return
	
	if !on_trigger.call(): return
	
	object.set_meta(WORK, 0)
	count -= 1
	
	if count > 0:
		object.set_meta(COUNT, count)
		return
	
	object.delete(true)

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
