extends Structure
class_name StructureEdge

static var Default = load("res://resource/structure/misc/StructureEdge.tres")

static var structureEdgePrefab = load("res://prefab/StructureEdgeObject.tscn")

const REQUIREMENTS := &"requirements"

func create_object() -> StructureObject:
	var object: StructureObject = structureEdgePrefab.instantiate()
	object.structure = self
	return object

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
		set_requirements(object, requirements)
	if requirements.is_empty():
		var temp_coordsi := object.coordsi
		object.delete()
		Gameplay.I.exploreMap(temp_coordsi)
	
func _update_view(object: StructureObject):
	super(object)
	var edgeObject := object as StructureEdgeObject
	if !edgeObject: return
	var requirements := get_requirements(object)
	edgeObject.imageTemplate.visible = false
	
	# delete all image
	for child in edgeObject.requirementGroup.get_children():
		if child == edgeObject.imageTemplate: continue
		child.queue_free()
	
	for requirement in requirements:
		var image: TextureRect = edgeObject.imageTemplate.duplicate()
		image.texture = requirement.texture
		image.visible = true
		edgeObject.requirementGroup.add_child(image)

func get_requirements(object: StructureObject) -> Array[Item]:
	var result: Array[Item] = []
	result.assign(object.get_data(REQUIREMENTS, []))
	return result

func set_requirements(object: StructureObject, requirements: Array[Item]):
	object.set_data(REQUIREMENTS, requirements)
	object._update_view()

func can_enter(object: StructureObject, input_dir: Constant.Direction):
	return true

func push_item_to(object: StructureObject, item: ItemObject, input_dir: Constant.Direction) -> bool:
	if !item: return true
	return get_requirements(object).has(item.item)
