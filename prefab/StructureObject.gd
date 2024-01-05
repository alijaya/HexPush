extends NodeTM
class_name StructureObject

@export var structure: Structure

@export var dir: Constant.Direction = Constant.Direction.S:
	set(v):
		dir = v
		_update_view()

@onready var sprite: Sprite2D = $Sprite2D
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

func _on_item_enter(item: ItemObject, input_dir: Constant.Direction):
	if structure: return structure._on_item_enter(self, item, input_dir)

func can_enter(input_dir: Constant.Direction) -> bool:
	if structure: return structure.can_enter(self, input_dir)
	return false

func get_output_dir(input_dir: Constant.Direction) -> Constant.Direction:
	if structure: return structure.get_output_dir(self, input_dir)
	return Constant.Direction.None

func rotateCCW():
	dir = posmod(dir+1, 6) as Constant.Direction

func rotateCW():
	dir = posmod(dir-1, 6) as Constant.Direction

func equals(other: Structure) -> bool:
	return structure.equals(other)