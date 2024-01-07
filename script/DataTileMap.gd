@tool
extends TileMap
class_name DataTileMap

var datas_key_coords := {}
var datas_coords_key := {}
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

func has_data(coords: Vector2i, key: StringName) -> bool:
	var cell = datas_coords_key.get(coords) # only check the coords -> key
	if !cell: return false
	return cell.has(key)

func get_data(coords: Vector2i, key: StringName, default: Variant = null) -> Variant:
	var cell = datas_coords_key.get(coords) # only check the coords -> key
	if !cell: return default
	return cell.get(key, default)

func get_data_cell(coords: Vector2i) -> Dictionary:
	return datas_coords_key.get(coords, {}).duplicate()

func get_data_layer(key: StringName) -> Dictionary:
	return datas_key_coords.get(key, {}).duplicate()

func erase_data(coords: Vector2i, key: StringName):
	var cell = datas_coords_key.get(coords)
	if cell:
		cell.erase(key)
		if cell.is_empty(): datas_coords_key.erase(coords)
	var layer = datas_key_coords.get(key)
	if layer:
		layer.erase(coords)
		if layer.is_empty(): datas_key_coords.erase(key)

func erase_data_cell(coords: Vector2i):
	var cell = datas_coords_key.get(coords)
	datas_coords_key.erase(coords)
	if !cell: return
	for key in cell.keys():
		var layer = datas_key_coords.get(key)
		if !layer: continue
		layer.erase(coords)
		if layer.is_empty(): datas_key_coords.erase(key)

func erase_data_layer(key: StringName):
	var layer = datas_key_coords.get(key)
	datas_key_coords.erase(key)
	if !layer: return
	for coords in layer.keys():
		var cell = datas_coords_key.get(coords)
		if !cell: continue
		cell.erase(key)
		if cell.is_empty(): datas_coords_key.erase(coords)

func set_data(coords: Vector2i, key: StringName, value: Variant):
	if value == null:
		erase_data(coords, key)
		return
	
	var cell = datas_coords_key.get(coords)
	if !cell:
		cell = {}
		datas_coords_key[coords] = cell
	cell[key] = value
	
	var layer = datas_key_coords.get(key)
	if !layer:
		layer = {}
		datas_key_coords[key] = layer
	layer[coords] = value
	
func set_data_cell(coords: Vector2i, cell: Dictionary):
	if !cell:
		erase_data_cell(coords)
		return
	datas_coords_key[coords] = cell.duplicate()
	for key in cell.keys():
		var value = cell[key]
		var layer = datas_key_coords.get(key)
		if !layer:
			layer = {}
			datas_key_coords[key] = layer
		layer[coords] = value

func set_data_layer(key: StringName, layer: Dictionary):
	if !layer:
		erase_data_layer(key)
		return
	datas_key_coords[key] = layer.duplicate()
	for coords in layer.keys():
		var value = layer[coords]
		var cell = datas_coords_key.get(coords)
		if !cell:
			cell = {}
			datas_coords_key[coords] = cell
		cell[key] = value

# Called when the node enters the scene tree for the first time.
#func _ready():
#	if Engine.is_editor_hint(): return
#	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
