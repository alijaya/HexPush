extends Item
class_name ItemStructure

@export var structure: Structure

func equals(other) -> bool:
	var otherItemStructure := other as ItemStructure
	return otherItemStructure and structure.equals(otherItemStructure.structure)
