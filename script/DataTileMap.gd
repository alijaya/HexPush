@tool
extends TileMap
class_name DataTileMap

var datas := {}
var hex_layout := HexLayout.new():
	get:
		hex_layout.is_flat = true
		hex_layout.size = Vector2(tile_set.tile_size) / 2
		hex_layout.size.y *= 2. / sqrt(3)
		return hex_layout

static var hex_unit_layout := HexLayout.new():
	get:
		hex_unit_layout.is_flat = true
		hex_unit_layout.size = Vector2.ONE / 2
		hex_unit_layout.size.y *= 2. / sqrt(3)
		return hex_unit_layout

func set_data(coords: Vector2i, key: StringName, value: Variant):
	var cell = datas.get(coords)
	if !cell:
		cell = {}
		datas[coords] = cell
	cell[key] = value
	
func set_data_cell(coords: Vector2i, dict: Dictionary):
	datas[coords] = dict

func get_data(coords: Vector2i, key: StringName, default: Variant = null) -> Variant:
	var cell = datas.get(coords)
	if !cell: return default
	return cell.get(key, default)

func get_data_cell(coords: Vector2i) -> Dictionary:
	return datas.get(coords)

func erase_data(coords: Vector2i, key: StringName):
	var cell = datas.get(coords)
	if !cell: return
	cell.erase(key)
	if cell.is_empty(): datas.erase(coords)

func erase_data_coords(coords: Vector2i):
	datas.erase(coords)

func erase_data_key(key: StringName):
	for coords in datas:
		var cell = datas.get(coords)
		if !cell: continue
		cell.erase(key)
		if cell.is_empty(): datas.erase(coords)

# Called when the node enters the scene tree for the first time.
#func _ready():
#	if Engine.is_editor_hint(): return
#	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
