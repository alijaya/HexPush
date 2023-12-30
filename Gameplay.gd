extends Node2D

onready var world = $YSort
onready var camera = $Camera2D

var hexTilePrefab = preload("res://HexTile.tscn")
var hexMap := {}
var layout: HexLayout
var lastHexes: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var size := 100
	var aspect := sqrt(3) / 2
	
	layout = HexLayout.new(true, Vector2(size, size * aspect), Vector2.ZERO)
	var hexes := Hex.create_map_hexagon(10)
	
	var rect: Rect2
	
	for hex in hexes:
		var pos := layout.hex_to_pixel(hex)
		var hexTile = hexTilePrefab.instance()
		hexTile.position.x = pos.x
		hexTile.position.y = pos.y
		world.add_child(hexTile)
		hexMap[hex] = hexTile
		
		if rect: rect = rect.expand(pos)
		else: rect = Rect2(pos, Vector2.ZERO)
	
	if !rect: rect = Rect2()
	camera.boundingRect = rect
	
func _unhandled_input(event):
	if "position" in event:
		var pos = $YSort.get_local_mouse_position()
		var hex = layout.pixel_to_hex(pos)
		
		resetTiles()
		lastHexes = Hex.hex_linedraw(Vector3.ZERO, hex)
		highlightTiles()

func resetTiles():
	for hex in lastHexes:
		var hexTile = hexMap.get(hex, null)
		if hexTile: hexTile.modulate = Color.white

func highlightTiles():
	for hex in lastHexes:
		var hexTile = hexMap.get(hex, null)
		if hexTile: hexTile.modulate = Color.green
