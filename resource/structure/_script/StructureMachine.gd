extends Structure
class_name StructureMachine

static var Sawmill = load("res://resource/structure/machine/StructureSawmill.tres")
static var Brickyard = load("res://resource/structure/machine/StructureBrickyard.tres")
static var Smelter = load("res://resource/structure/machine/StructureSmelter.tres")
static var LogisticShop = load("res://resource/structure/machine/StructureLogisticShop.tres")
static var Workshop = load("res://resource/structure/machine/StructureWorkshop.tres")

static var infoStructureMachinePrefab := load("res://prefab/info_panel/InfoStructureMachine.tscn")

@export var recipes: Array[Recipe]
@export var recipes_path: Array[String] # handling cyclic dependency

const TICK := &"tick"
const RECIPE := &"recipe"

func get_info_prefab(object: StructureObject) -> PackedScene:
	return infoStructureMachinePrefab

func get_all_recipes() -> Array[Recipe]:
	var new_recipes: Array[Recipe] = recipes.duplicate()
	for path in recipes_path:
		new_recipes.append(load(path))
	return new_recipes

func _update_view(object: StructureObject):
	super(object)
	object.dummy.direction_flags = 1 << object.dir

func get_recipe(object: StructureObject) -> Recipe:
	return object.get_data(RECIPE)

func set_recipe(object: StructureObject, recipe: Recipe):
	object.set_data(RECIPE, recipe)

func get_tick(object: StructureObject) -> int:
	return object.get_data(TICK, 0)

func set_tick(object: StructureObject, tick: int):
	object.set_data(TICK, tick)

func _step_tick(object: StructureObject):
	update_active_recipe(object)
	var active_recipe := get_recipe(object)
	if !active_recipe: return
	var tick := get_tick(object)
	tick += 1
	if tick < active_recipe.duration:
		set_tick(object, tick)
		return
	
	if !spawn(object): return
	
	consume_inputs(object)
	set_recipe(object, null)
	set_tick(object, 0)

func update_active_recipe(object: StructureObject):
	var inputs: Array[ItemObject] = get_inputs(object)
	# check recipe
	var active_recipe := get_recipe(object)
	var lastRecipe := active_recipe
	active_recipe = null
	var all_recipes := get_all_recipes()
	all_recipes.sort_custom(func (a, b): return a.inputs.size() > b.inputs.size())
	for recipe in all_recipes:
		var dup := recipe.inputs.duplicate()
		for input in inputs:
			if dup.has(input.item): dup.erase(input.item)
		
		if dup.is_empty():
			active_recipe = recipe
			break
	
	if active_recipe != lastRecipe:
		set_recipe(object, active_recipe)
		set_tick(object, 0)

func get_inputs(object: StructureObject) -> Array[ItemObject]:
	var result: Array[ItemObject] = []
	var output_coords := Coords.coords_neighbor(object.coordsi, object.dir)
	for coords in Coords.coords_ring(object.coordsi, 1):
		if coords == output_coords: continue
		var item := Gameplay.I.get_item(coords)
		if item: result.append(item)
	return result

func consume_inputs(object: StructureObject):
	var inputs: Array[ItemObject] = get_inputs(object)
	inputs.shuffle()
	
	var active_recipe := get_recipe(object)
	var dup := active_recipe.inputs.duplicate()
	for input in inputs:
		if dup.has(input.item):
			dup.erase(input.item)
			input.delete()

func spawn(object: StructureObject) -> bool:
	var active_recipe := get_recipe(object)
	var nex_coordsi := Coords.coords_neighbor(object.coordsi, object.dir)
	if Gameplay.I.push_item_to(null, nex_coordsi, object.dir):
		object.priority = 0
		Gameplay.I.add_item(object.coordsi, active_recipe.output, true)
		Gameplay.I.push_item_from(object.coordsi, object.dir)
		return true
	else:
		object.priority += 1
		return false
