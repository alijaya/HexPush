extends Item
class_name ItemStructure

@export var structure: Structure:
	set(v):
		structure = v
		if structure:
			name = structure.name
			color = structure.color
			texture = structure.texture

func equals(other) -> bool:
	var otherItemStructure := other as ItemStructure
	return otherItemStructure and structure.equals(otherItemStructure.structure)
