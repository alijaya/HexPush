extends Structure
class_name StructureHearth

static var Default = load("res://resource/structure/misc/StructureHearth.tres")

#static var infoStructureMachinePrefab := load("res://prefab/info_panel/InfoStructureMachine.tscn")

#func get_info_prefab(object: StructureObject) -> PackedScene:
	#return infoStructureMachinePrefab

func _step_tick(object: StructureObject):
	consume_inputs(object)

func get_inputs(object: StructureObject) -> Array[ItemObject]:
	var result: Array[ItemObject] = []
	for coords in Coords.coords_ring(object.coordsi, 1):
		var item := Gameplay.I.get_item(coords)
		if item: result.append(item)
	return result

func consume_inputs(object: StructureObject):
	var inputs: Array[ItemObject] = get_inputs(object)
	inputs.shuffle()
	
	for input in inputs:
		var burn_value := input.item.burn_value
		if burn_value < 0: continue
		if Gameplay.I.empty_hearth >= burn_value:
			Gameplay.I.hearth += burn_value
			input.delete()
