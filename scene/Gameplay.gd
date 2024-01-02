extends Node2D

@onready var camera: CameraMouseControl = $Camera2D
@onready var tilemap: DataTileMap = $TileMap

@export var bounding: Rect2i = Rect2i()
@export var mapGenerator: MapGenerator

var highlightedCoords: Array[Vector2i] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	generateMap()
	
	var coords := []
	for i in range(tilemap.get_layers_count()):
		coords.append_array(tilemap.get_used_cells(i))
#	var rect := tilemap.get_used_rect()
#	var coords := [rect.position, rect.position + Vector2i(rect.size.x-1, 0), rect.position + Vector2i(0, rect.size.y-1), rect.end - Vector2i.ONE]
	
	var boundingRect: Rect2
	
	for coord in coords:
		var pos := tilemap.to_global(tilemap.map_to_local(coord))
		if boundingRect: boundingRect = boundingRect.expand(pos)
		else: boundingRect = Rect2(pos, Vector2.ZERO)
	
	camera.boundingRect = boundingRect

func generateMap():
	mapGenerator.setup()
	var origin := Hex.flat_offset_to_hex(Hex.OffsetType.EVEN, bounding.position)
	var hexes := Hex.create_map_rectangle_flat(Hex.OffsetType.EVEN, bounding.size.x, bounding.size.y)
	var biomeCoords := {}
	for hex in hexes:
		hex = hex + origin
		var coords = Hex.hex_to_tilemap(hex)
		var uv = Hex.hex_to_pixel(DataTileMap.hex_unit_layout, hex)
		var biome = mapGenerator.f_biome.call(uv.x, uv.y)
		var feature = mapGenerator.f_feature.call(uv.x, uv.y)
		var list = biomeCoords.get(biome, [])
		list.append(coords)
		biomeCoords[biome] = list
		
		if biome != Constant.Biome.Water and feature != Constant.Feature.None:
			var tile = Constant.FeatureToTiles[feature].pick_random()
			tilemap.set_cell(Constant.Layer.Feature, coords, tile[0], tile[1], tile[2])
	
	for biome in biomeCoords:
		var list = biomeCoords.get(biome, [])
		BetterTerrain.set_cells(tilemap, Constant.BiomeToLayer[biome], list, Constant.BiomeToTerrain[biome])
		BetterTerrain.update_terrain_cells(tilemap, Constant.BiomeToLayer[biome], list)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var mouse := tilemap.get_local_mouse_position()
	var pos := tilemap.local_to_map(mouse)
	
	clear_selection()
	
	highlightedCoords.assign(Hex.hex_ring(Hex.tilemap_to_hex(pos), 2).map(func (hex): return Hex.hex_to_tilemap(hex)))
	add_selection(highlightedCoords)

func _unhandled_input(event):
	var mb := event as InputEventMouseButton
	if !mb: return
	
	if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
		for coords in highlightedCoords:
			var tree = Constant.FeatureToTiles[Constant.Feature.Tree].pick_random()
			add_feature(coords, tree[0], tree[1], tree[2])

func clear_selection():
	tilemap.clear_layer(Constant.Layer.Selection)

func add_selection(selections: Array[Vector2i]):
	BetterTerrain.set_cells(tilemap, Constant.Layer.Selection, selections, Constant.SelectionTerrain)
	BetterTerrain.update_terrain_cells(tilemap, Constant.Layer.Selection, selections, Constant.SelectionTerrain)
#	tilemap.set_cells_terrain_connect(selectionLayer, selections, selectionTerrainSet, selectionTerrain)

func add_feature(coords: Vector2i, sourceID: int, atlasCoords: Vector2i, alternativeTile: int = 0):
	tilemap.set_cell(Constant.Layer.Feature, coords, sourceID, atlasCoords, alternativeTile)
