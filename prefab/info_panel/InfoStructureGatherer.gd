extends InfoStructure
class_name InfoStructureGatherer

@onready var tickProgressBar: ProgressBar = $TickProgressBar
@onready var workProgressBar: ProgressBar = $WorkProgressBar

func _process(_delta):
	super(_delta)
	if is_instance_valid(structure):
		var structureGatherer := structure.structure as StructureGatherer
		if structureGatherer:
			var resource := structureGatherer.get_resource(structure)
			var tick := structureGatherer.get_tick(structure)
			tickProgressBar.max_value = structureGatherer.tickPerClick - 1
			tickProgressBar.value = tick
			if is_instance_valid(resource):
				var structureResource := resource.structure as StructureResource
				var work := structureResource.get_work(resource)
				if structureResource:
					workProgressBar.max_value = structureResource.hardness - 1
					workProgressBar.value = work
