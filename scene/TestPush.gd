extends Node2D

@export var cell_size: float = 100
var dummyPrefab: PackedScene = preload("res://prefab/Dummy.tscn")

enum Dir {UP, RIGHT, DOWN, LEFT, NONE = -1}
enum Type {
	EMPTY,
	GENERATOR,
	BLOCKER,
	COMBINER,
	BUBBLER,
}

enum State {
	NOTHING,
	TRY,
	ACCEPT,
	REJECT,
}

var dirs_v: Array[Vector2i] = [
	Vector2i(0, -1), # top
	Vector2i(1, 0), # right
	Vector2i(0, 1), # bottom
	Vector2i(-1, 0), # left
]

var gens := [
	[Vector2i(4,0), Dir.DOWN, Color.AQUA],
	[Vector2i(1,2), Dir.RIGHT, Color.CORAL],
	[Vector2i(5,4), Dir.LEFT, Color.GREEN_YELLOW],
]

var blocks := [
	[Vector2i(4, 8)],
	[Vector2i(15, 6)],
]

var combs := [
	[Vector2i(6, 2), Dir.DOWN],
	[Vector2i(4, 4), Dir.LEFT],
	[Vector2i(6, 6), Dir.RIGHT],
	[Vector2i(2, 6), Dir.UP],
]

var bubs := [
	[Vector2i(6, 4), Dir.DOWN],
]

var maps := {}

# action: bakal gerak kemana
# from_dirs: set dari mana aja
# to_dirs: set ke mana aja
# visited: is visited by dfs
var datas := {}

var stack: Array[Vector2i] = []

func get_obj(coordsi: Vector2i):
	var obj = maps.get(coordsi, null)
	if !obj:
		obj = {
			type = Type.EMPTY
		}
		maps[coordsi] = obj
	return obj

func get_data(coordsi: Vector2i):
	var data = datas.get(coordsi, null)
	if !data:
		data = {
			confirmed = false,
			visited = false,
		}
		datas[coordsi] = data
	return data

# Called when the node enters the scene tree for the first time.
func _ready():
	for generator in gens:
		var dummy := create_generator(generator[0], generator[2])
		add_child(dummy)
		
		var data: Dictionary = {}
		data.type = Type.GENERATOR
		data.generator = generator
		data.wait = 0
		data.generator_dummy = dummy
		maps[generator[0]] = data
	
	for blocker in blocks:
		var dummy := create_block(blocker[0])
		add_child(dummy)
		
		var data: Dictionary = {}
		data.type = Type.BLOCKER
		data.blocker = blocker
		data.blocker_dummy = dummy
		maps[blocker[0]] = data
	
	for combiner in combs:
		var dummy := create_combiner(combiner[0], combiner[1])
		add_child(dummy)
		
		var data: Dictionary = {}
		data.type = Type.COMBINER
		data.combiner = combiner
		data.combiner_dummy = dummy
		maps[combiner[0]] = data
	
	for bubbler in bubs:
		var dummy := create_bubbler(bubbler[0], bubbler[1])
		add_child(dummy)
		
		var data: Dictionary = {}
		data.type = Type.BUBBLER
		data.bubbler = bubbler
		data.wait = 0
		data.bubbler_dummy = dummy
		maps[bubbler[0]] = data

func _unhandled_input(event):
	var mb := event as InputEventMouseButton
	if !mb: return
	if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
		step()

func coords_to_pixel(coords: Vector2) -> Vector2:
	return (coords + Vector2.ONE * 0.5) * cell_size

func create_dummy(pos: Vector2, size: float, text: String, color: Color = Color.WHITE, text_color: Color = Color.BLACK, direction_flags: int = 0) -> Dummy:
	var dummy: Dummy = dummyPrefab.instantiate()
	dummy.position = pos
	dummy.width = size
	dummy.height = size
	dummy.text = text
	dummy.color = color
	dummy.text_color = text_color
	dummy.direction_flags = direction_flags
	return dummy

func create_generator(coordsi: Vector2i, color: Color) -> Dummy:
	return create_dummy(coords_to_pixel(coordsi), cell_size, "G", color)

func create_combiner(coordsi: Vector2i, dir: Dir) -> Dummy:
	return create_dummy(coords_to_pixel(coordsi), cell_size, "C", Color.YELLOW, Color.BLACK, 1<<dir)

func create_item(coordsi: Vector2i, color: Color) -> Dummy:
	return create_dummy(coords_to_pixel(coordsi), cell_size * .7, "I", color)

func create_block(coordsi: Vector2i) -> Dummy:
	return create_dummy(coords_to_pixel(coordsi), cell_size, "B", Color.BLACK, Color.WHITE)

func create_bubbler(coordsi: Vector2i, dir: Dir) -> Dummy:
	return create_dummy(coords_to_pixel(coordsi), cell_size, "BB", Color.CORNFLOWER_BLUE, Color.BLACK, 1<<dir)

func step():
	datas.clear()
	gens.sort_custom(func (a, b): return get_obj(a[0]).wait > get_obj(b[0]).wait)
	for gen in gens:
		var obj = get_obj(gen[0])
		#var can_push = check_can_push(gen[0], gen[1])
		if push_object(gen[0], gen[1]):
			obj.wait = 0
			var dummy = create_item(gen[0], obj.generator_dummy.color.lightened(0.5))
			add_child(dummy)
			obj.item = {}
			obj.item_dummy = dummy
		else:
			obj.wait += 1
		
	
	bubs.sort_custom(func (a, b): return get_obj(a[0]).wait > get_obj(b[0]).wait)
	for bub in bubs:
		var obj = get_obj(bub[0])
		#var can_push = check_can_push(bub[0], bub[1])
		if push_object(bub[0], bub[1]):
			obj.wait = 0
			var dummy = create_item(bub[0], obj.bubbler_dummy.color.lightened(0.5))
			add_child(dummy)
			obj.item = {is_bubble = true}
			obj.item_dummy = dummy
		else:
			obj.wait += 1

func push_object(coordsi: Vector2i, dir: Dir) -> bool:
	var obj = get_obj(coordsi)
	var data = get_data(coordsi)
	
	var result := false
	if !obj.has("item"): result = true
	else:
		var item = obj.item
		var dummy = obj.item_dummy
		var nex_dir := dir
		if obj.type == Type.COMBINER: nex_dir = obj.combiner[1]
		
		var nex_coordsi := coordsi + dirs_v[nex_dir]
		if can_enter(nex_coordsi, nex_dir) and push_object(nex_coordsi, nex_dir):
			obj.erase("item")
			obj.erase("item_dummy")
			var tween := get_tree().create_tween().bind_node(dummy)
			tween.tween_property(dummy, "position", coords_to_pixel(nex_coordsi), 1./4)
			var nex_obj = get_obj(nex_coordsi)
			nex_obj.item = item
			nex_obj.item_dummy = dummy
			result = true
		elif item.get("is_bubble", false):
			# pop bubble
			var tween := get_tree().create_tween().bind_node(dummy)
			tween.tween_property(dummy, "scale", Vector2.ZERO, 1./4)
			tween.tween_callback(func (): remove_child(dummy))
			result = true
	
	if result: data.confirmed = true
	return result

func can_enter(coordsi: Vector2i, dir: Dir):
	var data = get_data(coordsi)
	var obj = get_obj(coordsi)
	if data.confirmed: return false
	if obj.type == Type.GENERATOR or obj.type == Type.BLOCKER: return false
	elif obj.type == Type.BUBBLER: return dir == obj.bubbler[1]
	else: return true

func tab(depth: int):
	var str := ""
	for i in range(depth): str += "\t"
	return str
