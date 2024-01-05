extends Resource
class_name Item

@export var texture: Texture2D
@export var name: String = ""
@export var color: Color = Color.WHITE

static var itemPrefab = load("res://prefab/ItemObject.tscn")

func create_object() -> ItemObject:
	var object: ItemObject = itemPrefab.instantiate()
	object.item = self
	return object

func _ready(object: ItemObject):
	object.dummy.text = name
	object.dummy.color = color

func _process(object: ItemObject, delta: float):
	pass

func _step_tick(object: ItemObject):
	pass

func equals(other: Item) -> bool:
	return self == other
