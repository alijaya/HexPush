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

signal state_changed

var custom_data: Dictionary = {}

func _ready():
	_update_view()
	if structure: structure._ready(self)

func _process(delta: float):
	if structure: structure._process(self, delta)
	
func _step_tick():
	if structure: structure._step_tick(self)

func _update_view():
	if structure: structure._update_view(self)

func _on_item_enter(item: ItemObject, input_dir: Constant.Direction):
	if structure: return structure._on_item_enter(self, item, input_dir)

func _on_item_exit(item: ItemObject, output_dir: Constant.Direction):
	if structure: return structure._on_item_exit(self, item, output_dir)
	
func push_item_to(item: ItemObject, input_dir: Constant.Direction) -> bool:
	if structure: return structure.push_item_to(self, item, input_dir)
	return false

func _on_left_click():
	if structure: return structure._on_left_click(self)

func _on_left_hold():
	if structure: return structure._on_left_hold(self)

func _on_right_click():
	if structure: return structure._on_right_click(self)

func _on_right_hold():
	if structure: return structure._on_right_hold(self)

func create_info() -> InfoStructure:
	if structure:
		var prefab := structure.get_info_prefab(self)
		var info: InfoStructure = prefab.instantiate()
		info.structure = self
		return info
	return null

func is_flat() -> bool:
	if structure: return structure.is_flat()
	return false

func can_enter(input_dir: Constant.Direction) -> bool:
	if structure: return structure.can_enter(self, input_dir)
	return false

func can_accept_multiple() -> bool:
	if structure: return structure.can_accept_multiple()
	return false

func rotateCCW():
	dir = posmod(dir+1, 6) as Constant.Direction

func rotateCW():
	dir = posmod(dir-1, 6) as Constant.Direction

func pack_structure() -> ItemObject:
	if !structure: return null
	if !structure.can_pack(): return null
	if self != Gameplay.I.get_structure(coordsi): return null # not matching
	if Gameplay.I.get_item(coordsi): return null # can't pack structure on item
	
	delete(true) # delete this item
	var itemStructure := ItemStructure.new()
	itemStructure.structure = structure
	return Gameplay.I.add_item(coordsi, itemStructure, true)

func delete(animate: bool = false):
	if self == Gameplay.I.get_structure(coordsi):
		Gameplay.I.set_structure(coordsi, null)
	if structure: structure.delete(self, animate)
	if animate:
		var tween := create_tween().bind_node(self)
		tween.tween_property(self, "scale", Vector2.ZERO, Gameplay.I.secondsPerTick/4)
		tween.tween_callback(func (): queue_free())
	else: queue_free()

func equals(other: Structure) -> bool:
	if structure: return structure.equals(other)
	return false

func get_data(key: StringName, default: Variant = null):
	return custom_data.get(key, default)

func erase_data(key: StringName):
	custom_data.erase(key)

func set_data(key: StringName, value: Variant):
	if value == null:
		erase_data(key)
		return
	custom_data[key] = value
