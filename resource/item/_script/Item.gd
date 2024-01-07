extends Resource
class_name Item

@export var texture: Texture2D
@export var name: String = ""
@export var color: Color = Color.WHITE

@export var burn_value: int = -1

static var itemPrefab = load("res://prefab/ItemObject.tscn")
static var infoItemPrefab = load("res://prefab/info_panel/InfoItem.tscn")

static var ItemWood = load("res://resource/item/ItemWood.tres")
static var ItemPlank = load("res://resource/item/ItemPlank.tres")
static var ItemStone = load("res://resource/item/ItemStone.tres")
static var ItemBrick = load("res://resource/item/ItemBrick.tres")
static var ItemIronOre = load("res://resource/item/ItemIronOre.tres")
static var ItemIronPlate = load("res://resource/item/ItemIronPlate.tres")
static var ItemCoal = load("res://resource/item/ItemCoal.tres")

func create_object() -> ItemObject:
	var object: ItemObject = itemPrefab.instantiate()
	object.item = self
	return object

func create_info(object: ItemObject) -> InfoItem:
	var info: InfoItem = infoItemPrefab.instantiate()
	info.item = object
	return info

func _ready(object: ItemObject):
	pass

func _update_view(object: ItemObject):
	if texture:
		object.sprite.visible = true
		object.sprite.texture = texture
		object.dummy.visible = false
	else:
		object.dummy.visible = true
		object.dummy.text = name
		object.dummy.color = color
		object.dummy.text_color = Color.BLACK
		object.sprite.visible = false

func _process(object: ItemObject, delta: float):
	pass

func _step_tick(object: ItemObject):
	pass

func equals(other: Item) -> bool:
	return self == other
