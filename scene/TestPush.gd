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

static func get_flag(b: int, i: int) -> bool:
	return b & (1 << i) != 0

static func set_flag(b: int, i: int) -> int:
	return b | (1 << i)

static func unset_flag(b: int, i: int) -> int:
	return b & ~(1 << i)

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

func create_dummy(pos: Vector2, size: float, text: String, color: Color = Color.WHITE, text_color: Color = Color.BLACK) -> Dummy:
	var dummy: Dummy = dummyPrefab.instantiate()
	dummy.position = pos
	dummy.width = size
	dummy.height = size
	dummy.text = text
	dummy.color = color
	dummy.text_color = text_color
	return dummy

func create_generator(coordsi: Vector2i, color: Color) -> Dummy:
	return create_dummy(coords_to_pixel(coordsi), cell_size, "G", color)

func create_combiner(coordsi: Vector2i, dir: Dir) -> Dummy:
	return create_dummy(coords_to_pixel(coordsi), cell_size, ["^",">","v","<"][dir], Color.YELLOW)

func create_item(coordsi: Vector2i, color: Color) -> Dummy:
	return create_dummy(coords_to_pixel(coordsi), cell_size * .7, "I", color)

func create_block(coordsi: Vector2i) -> Dummy:
	return create_dummy(coords_to_pixel(coordsi), cell_size, "B", Color.BLACK, Color.WHITE)

func create_bubbler(coordsi: Vector2i, dir: Dir) -> Dummy:
	return create_dummy(coords_to_pixel(coordsi), cell_size, ["^",">","v","<"][dir], Color.CORNFLOWER_BLUE)

func step():
	datas.clear()
	gens.sort_custom(func (a, b): return get_obj(a[0]).wait > get_obj(b[0]).wait)
	for gen in gens:
		var obj = get_obj(gen[0])
		var can_push = check_can_push(gen[0], gen[1])
		if !can_push:
			obj.wait += 1
			continue
		obj.wait = 0
		var dummy = create_item(gen[0], obj.generator_dummy.color.lightened(0.5))
		add_child(dummy)
		obj.item = {}
		obj.item_dummy = dummy
		push_object(gen[0], gen[1], true)
	
	bubs.sort_custom(func (a, b): return get_obj(a[0]).wait > get_obj(b[0]).wait)
	for bub in bubs:
		var obj = get_obj(bub[0])
		var can_push = check_can_push(bub[0], bub[1])
		if !can_push:
			obj.wait += 1
			continue
		obj.wait = 0
		push_object(bub[0], bub[1], true)
		var dummy = create_item(bub[0], obj.bubbler_dummy.color.lightened(0.5))
		add_child(dummy)
		obj.item = {is_bubble = true}
		obj.item_dummy = dummy

func push_object(coordsi: Vector2i, dir: Dir, force: bool = false) -> bool:
	var obj = get_obj(coordsi)
	var data = get_data(coordsi)
	data.confirmed = true
	if !force and !can_enter(coordsi, dir): return false
	if !obj.has("item"): return true
	
	var item = obj.item
	var dummy = obj.item_dummy
	var nex_dir := dir
	if obj.type == Type.COMBINER: nex_dir = obj.combiner[1]
	
	var nex_coordsi := coordsi + dirs_v[nex_dir]
	if push_object(nex_coordsi, nex_dir):
		obj.erase("item")
		obj.erase("item_dummy")
		var tween := get_tree().create_tween().bind_node(dummy)
		tween.tween_property(dummy, "position", coords_to_pixel(nex_coordsi), 1./4)
		var nex_obj = get_obj(nex_coordsi)
		nex_obj.item = item
		nex_obj.item_dummy = dummy
		return true
	elif item.get("is_bubble", false):
		remove_child(dummy)
		return true
		# pop bubble
	
	return false

func can_enter(coordsi: Vector2i, dir: Dir):
	var obj = get_obj(coordsi)
	if obj.type == Type.GENERATOR or obj.type == Type.BLOCKER: return false
	elif obj.type == Type.BUBBLER: return dir == obj.bubbler[1]
	else: return true

func check_can_push(coordsi: Vector2i, dir: Dir):
	var data = get_data(coordsi)
	var obj = get_obj(coordsi)
	if data.confirmed or data.visited: return false
	data.visited = true
	
	var nex_coordsi := coordsi + dirs_v[dir]
	var nex_data = get_data(nex_coordsi)
	var nex_obj = get_obj(nex_coordsi)
	
	if nex_data.confirmed or nex_data.visited: return false
	var result: bool = false
	if nex_obj.type == Type.EMPTY or nex_obj.type == Type.COMBINER:
		if !nex_obj.has("item"): result = true
		elif nex_obj.type == Type.EMPTY:
			result = check_can_push(nex_coordsi, dir)
		elif nex_obj.type == Type.COMBINER:
			result = check_can_push(nex_coordsi, nex_obj.combiner[1])
	elif nex_obj.type == Type.BUBBLER:
		if dir == nex_obj.bubbler[1]:
			if !nex_obj.has("item"): result = true
			else:
				result = check_can_push(nex_coordsi, nex_obj.bubbler[1])
		else: result = false
	
	if !result: # check if this is bubble
		if obj.get("item", {}).get("is_bubble", false): result = true
	nex_data.visited = false
	return result

func tab(depth: int):
	var str := ""
	for i in range(depth): str += "\t"
	return str