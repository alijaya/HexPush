extends InfoStructure
class_name InfoStructureResource

@onready var countLabel: Label = $CountLabel
@onready var workProgressBar: ProgressBar = $WorkProgressBar

func _process(_delta):
	super(_delta)
	if is_instance_valid(structure):
		var structureResource := structure.structure as StructureResource
		if structureResource:
			countLabel.text = str(structureResource.get_count(structure))
			workProgressBar.max_value = structureResource.hardness
			workProgressBar.value = structureResource.get_work(structure)
