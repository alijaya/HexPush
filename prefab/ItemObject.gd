extends NodeTM
class_name ItemObject

@export var item: Item

@onready var sprite: Sprite2D = $Sprite2D
@onready var dummy: DummyHex = $DummyHex

func _ready():
	_update_view()
	if item: item._ready(self)

func _update_view():
	if item: item._update_view(self)

func _process(delta: float):
	if item: item._process(self, delta)
	
func _step_tick():
	if item: item._step_tick(self)

func equals(other: Item) -> bool:
	return item.equals(other)

func create_info() -> InfoItem:
	if item: return item.create_info(self)
	return null

func build_structure() -> StructureObject:
	var itemStructure := item as ItemStructure
	if !itemStructure: return null
	if self != Gameplay.I.get_item(coordsi): return null # not matching
	if Gameplay.I.get_structure(coordsi): return null # can't build on structure
	
	delete(true) # delete this item
	return Gameplay.I.add_structure(coordsi, itemStructure.structure, true)

func delete(animate: bool = false):
	if self == Gameplay.I.get_item(coordsi):
		Gameplay.I.set_item(coordsi, null)
	#Gameplay.I.items.erase(self)
	if animate:
		var tween := create_tween().bind_node(self)
		tween.tween_property(self, "scale", Vector2.ZERO, Gameplay.I.secondsPerTick/4)
		tween.tween_callback(func (): queue_free())
	else: queue_free()
