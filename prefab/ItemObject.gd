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

func delete(animate: bool = false):
	if self == Gameplay.I.get_item(coordsi):
		Gameplay.I.set_item(coordsi, null)
	Gameplay.I.items.erase(self)
	if animate:
		var tween := create_tween().bind_node(self)
		tween.tween_property(self, "scale", Vector2.ZERO, Gameplay.I.secondsPerTick/4)
		tween.tween_callback(func (): queue_free())
	else: queue_free()
