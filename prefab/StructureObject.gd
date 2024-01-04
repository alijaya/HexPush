extends NodeTM
class_name StructureObject

@export var structure: Structure

@export var dir: Constant.Direction = Constant.Direction.S:
	set(v):
		dir = v
		_update_view()

@onready var dummy: DummyHex = $DummyHex

var priority: int = 0

func _ready():
	if structure:
		structure._update_view(self)
		structure._ready(self)

func _process(delta: float):
	if structure: structure._process(self, delta)
	
func _step_tick():
	if structure: structure._step_tick(self)

func _update_view():
	if structure: structure._update_view(self)

func rotateCCW():
	dir = posmod(dir+1, 6) as Constant.Direction

func rotateCW():
	dir = posmod(dir-1, 6) as Constant.Direction

func equals(other: Structure) -> bool:
	return structure.equals(other)
