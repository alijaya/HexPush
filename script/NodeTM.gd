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
	get: return Hex.tilemap_to_hex(coords)
	set(v):
		coords = Hex.hex_to_tilemap(v)

var hexi: Vector3i:
	get: return Hex.hex_round(hex)
	set(v):
		hex = v

var coordsi: Vector2i:
	get: return Hex.hex_to_tilemap(hexi)
	set(v):
		coords = v

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
	var local_pos := Hex.hex_to_pixel(hex_layout, hex)
	global_position = tilemap.to_global(local_pos + Vector2(tilemap.tile_set.tile_size)/2)
