@tool
extends NodeTM
class_name Generator

@export var item: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint(): return
	
	while true:
		var ins: NodeTM = item.instantiate()
		ins.coordsi = coordsi
		tilemap.add_child.call_deferred(ins)
		tilemap.set_data(coordsi, "item", ins)
		push_object(ins, Hex.FlatDir.NE)
		await get_tree().create_timer(2).timeout

func push_object(obj: NodeTM, dir: Vector3i):
	tilemap.erase_data(obj.coordsi, "item")
	var t_coordsi := Hex.hex_to_tilemap(obj.hexi + Hex.FlatDir.NE)
	var c_item = tilemap.get_data(t_coordsi, "item")
	if c_item:
		push_object(c_item, dir)
	var tween := get_tree().create_tween().bind_node(obj)
	tween.tween_property(obj, "coords", t_coordsi, 1)
	tilemap.set_data(t_coordsi, "item", obj)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
