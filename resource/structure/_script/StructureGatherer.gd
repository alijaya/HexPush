extends Structure
class_name StructureGatherer

static var LumberCamp = load("res://resource/structure/StructureLumberCamp.tres")
static var Quarry = load("res://resource/structure/StructureQuarry.tres")

static var infoStructureGathererPrefab := load("res://prefab/info_panel/InfoStructureGatherer.tscn")

@export var resourceType: StructureResource
@export var tickPerClick: int = 1

const TICK := &"tick"
const RESOURCE := &"resource"

func get_info_prefab(object: StructureObject) -> PackedScene:
	return infoStructureGathererPrefab

func get_resource(object: StructureObject) -> StructureObject:
	if object.has_meta(RESOURCE):
		return object.get_meta(RESOURCE)
	else: return null

func set_resource(object: StructureObject, resource: StructureObject):
	object.set_meta(RESOURCE, resource)

func get_tick(object: StructureObject) -> int:
	return object.get_meta(TICK, 0)

func set_tick(object: StructureObject, tick: int):
	object.set_meta(TICK, tick)

func _ready(object: StructureObject):
	object.set_meta(TICK, 0)

func _update_view(object: StructureObject):
	super(object)
	object.dummy.direction_flags = 1 << object.dir

func _step_tick(object: StructureObject):
	var tick := get_tick(object)
	tick += 1
	if tick < tickPerClick:
		set_tick(object, tick)
		return
	
	if !work(object): return
	
	set_tick(object, 0)

func work(object: StructureObject) -> bool:
	var resource := get_resource(object)
	if !resource:
		var search_coords := Coords.coords_ring(object.coordsi, 1)
		search_coords.shuffle()
		for coords in search_coords:
			var structure := Gameplay.I.get_structure(coords)
			if structure and structure.equals(resourceType):
				resource = structure
				set_resource(object, resource)
				break
	if !resource: return false
	resourceType.work(resource, func (): return spawn(object))
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
