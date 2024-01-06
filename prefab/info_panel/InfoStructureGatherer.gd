extends InfoStructure
class_name InfoStructureGatherer

@onready var tickProgressBar: ProgressBar = $WorkProgressBar
@onready var workProgressBar: ProgressBar = $WorkProgressBar

func _process(_delta):
	super(_delta)
	if is_instance_valid(structure):
		var structureGatherer := structure.structure as StructureGatherer
		if structureGatherer:
			var resource := structureGatherer.get_resource(structure)
			var tick := structureGatherer.get_tick(structure)
			tickProgressBar.max_value = structureGatherer.tickPerClick
			tickProgressBar.value = tick
			if is_instance_valid(resource):
				var structureResource := resource.structure as StructureResource
				if structureResource:
					workProgressBar.max_value = structureResource.hardness
					workProgressBar.value = structureResource.get_work(resource)
