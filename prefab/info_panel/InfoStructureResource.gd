extends InfoStructure
class_name InfoStructureResource

@onready var countLabel: Label = $CountLabel
@onready var workProgressBar: ProgressBar = $WorkProgressBar

func _process(_delta):
	super(_delta)
	if is_instance_valid(structure):
		var structureResource := structure.structure as StructureResource
		if structureResource:
			countLabel.text = str(structure.get_meta(StructureResource.COUNT, 0))
			workProgressBar.max_value = structureResource.hardness
			workProgressBar.value = structure.get_meta(StructureResource.WORK, 0)
