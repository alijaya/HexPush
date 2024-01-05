@tool
extends Node2D
class_name NodeTM

var _coords := Vector2(0, 0)
@export var ns: float:
	get: return _coords.x
	set(v):
		_coords.x = v
		_update_position()

@export var r: float:
	get: return _coords.y
	set(v):
		_coords.y = v
		_update_position()
	
var coords: Vector2:
	get: return _coords
	set(v):
		_coords = v
		_update_position()

var hex: Vector3:
	get: return Coords.coords_to_hex(coords)
	set(v):
		coords = Coords.hex_to_coords(v)

var hexi: Vector3i:
	get: return Hex.hex_round(hex)
	set(v):
		hex = v

var coordsi: Vector2i:
	get: return Coords.coords_round(coords)
	set(v):
		coords = v

var _offset_coords := Vector2(0, 0)
@export var offset_ns: float:
	get: return _offset_coords.x
	set(v):
		_offset_coords.x = v
		_update_position()

@export var offset_r: float:
	get: return _offset_coords.y
	set(v):
		_offset_coords.y = v
		_update_position()
	
var offset_coords: Vector2:
	get: return _offset_coords
	set(v):
		_offset_coords = v
		_update_position()

var offset_hex: Vector3:
	get: return Coords.coords_to_hex(coords)
	set(v):
		coords = Coords.hex_to_coords(v)

var tilemap: DataTileMap
var hex_layout: HexLayout:
	get:
		if !tilemap: return null
		return tilemap.hex_layout

func _enter_tree():
	_find_tilemap()
	_update_position()

func _find_tilemap():
	var parent := get_parent()
	while parent:
		if parent is DataTileMap:
			tilemap = parent
			break
		elif parent is NodeTM:
			tilemap = parent.tilemap
			break
		else:
			parent = parent.get_parent()

func _update_position():
	if !hex_layout: return
	var local_pos := Coords.coords_to_pixel(hex_layout, coords + offset_coords)
	global_position = tilemap.to_global(local_pos + Vector2(tilemap.tile_set.tile_size)/2)

func reset_offset():
	offset_coords = Vector2.ZERO

func set_offset_dir(dir: int):
	offset_coords = Coords.coords_direction(dir)

func set_offset_neg_dir(dir: int):
	offset_coords = -Coords.coords_direction(dir)

func set_coords_keep_position(to_coords: Vector2):
	_offset_coords = coords - to_coords
	_coords = to_coords
	_update_position()
