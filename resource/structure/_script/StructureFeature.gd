extends Structure
class_name StructureFeature

static var Feature:= {
	Constant.Feature.Tree : load("res://resource/structure/StructureTree.tres"),
	Constant.Feature.Rock : load("res://resource/structure/StructureRock.tres"),
}

func _ready(object: StructureObject):
	pass

func _step_tick(object: StructureObject):
	pass
