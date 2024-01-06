extends Structure
class_name StructureGatherer

static var LumberCamp = load("res://resource/structure/StructureLumberCamp.tres")
static var Quarry = load("res://resource/structure/StructureQuarry.tres")

@export var resourceType: StructureResource
@export var tickPerClick: int = 1

const TICK := &"tick"
const RESOURCE := &"resource"

func _ready(object: StructureObject):
	object.set_meta(TICK, 0)

func _update_view(object: StructureObject):
	super(object)
	object.dummy.direction_flags = 1 << object.dir

func _step_tick(object: StructureObject):
	var tick: int = object.get_meta(TICK, 0)
	tick += 1
	if tick < tickPerClick:
		object.set_meta(TICK, tick)
		return
	
	if !work(object): return
	
	object.set_meta(TICK, 0)

func work(object: StructureObject) -> bool:
	if !object.has_meta(RESOURCE) or !object.get_meta(RESOURCE):
		var search_coords := Coords.coords_ring(object.coordsi, 1)
		search_coords.shuffle()
		for coords in search_coords:
			var structure := Gameplay.I.get_structure(coords)
			if structure and structure.equals(resourceType):
				object.set_meta(RESOURCE, structure)
				break
	if !object.has_meta(RESOURCE) or !object.get_meta(RESOURCE): return false
	resourceType.work(object.get_meta(RESOURCE), func (): return spawn(object))
	return true

func spawn(object: StructureObject) -> bool:
	var nex_coordsi := Coords.coords_neighbor(object.coordsi, object.dir)
	if Gameplay.I.push_item_to(null, nex_coordsi, object.dir):
		object.priority = 0
		Gameplay.I.add_item(object.coordsi, resourceType.output, true)
		Gameplay.I.push_item_from(object.coordsi, object.dir)
		return true
	else:
		object.priority += 1
		return false
