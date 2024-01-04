extends NodeTM
class_name ItemObject

@export var item: Item

@onready var dummy: DummyHex = $DummyHex

func _ready():
	if item: item._ready(self)

func _process(delta: float):
	if item: item._process(self, delta)
	
func _step_tick():
	if item: item._step_tick(self)

func equals(other: Item) -> bool:
	return item.equals(other)
