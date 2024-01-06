extends InfoPanel
class_name InfoStructure

@export var structure: StructureObject

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	categoryLabel.text = "Structure"
	if is_instance_valid(structure) and structure.structure:
		sprite.texture = structure.structure.texture
		titleLabel.text = structure.structure.name
	else:
		queue_free()
