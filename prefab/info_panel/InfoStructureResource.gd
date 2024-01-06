extends InfoStructure
class_name InfoStructureResource

@onready var countLabel: Label = $CountLabel
@onready var workProgressBar: ProgressBar = $WorkProgressBar

func _process(_delta):
	super(_delta)
	if is_instance_valid(structure):
		var structureResource := structure.structure as StructureResource
		var count := structureResource.get_count(structure)
		var work := structureResource.get_work(structure)
		if structureResource:
			countLabel.text = str(count)
			workProgressBar.max_value = structureResource.hardness - 1
			workProgressBar.value = work
