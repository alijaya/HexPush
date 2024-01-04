extends Node2D
class_name Gameplay

static var I: Gameplay

@onready var secondsPerTick: float = 1.
@onready var camera: CameraMouseControl = $Camera2D
@onready var tilemap: DataTileMap = $TileMap

@export var bounding: Rect2i = Rect2i()
@export var mapGenerator: MapGenerator

var structureToAdd := {
	Key.KEY_1: StructureGenerator.Default,
}

var highlightedCoords: Array[Vector2i] = []
var structures: Array[StructureObject] = []
var items: Array[ItemObject] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	I = self
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
	
	loop()

func generateMap():
	mapGenerator.setup()
	var origin := Coords.flat_offset_to_coords(Hex.OffsetType.EVEN, bounding.position)
	var coordss := Coords.create_map_rectangle_flat(Hex.OffsetType.EVEN, bounding.size.x, bounding.size.y)
	var biomeCoords := {}
	for coords in coordss:
		coords = coords + origin
		var uv = Coords.coords_to_pixel(DataTileMap.hex_unit_layout, coords)
		var biome = mapGenerator.f_biome.call(uv.x, uv.y)
		var feature = mapGenerator.f_feature.call(uv.x, uv.y)
		var list = biomeCoords.get(biome, [])
		list.append(coords)
		biomeCoords[biome] = list
		
		if biome != Constant.Biome.Water and feature != Constant.Feature.None:
			#var tile = Constant.FeatureToTiles[feature].pick_random()
			#tilemap.set_cell(Constant.Layer.Feature, coords, tile[0], tile[1], tile[2])
			add_structure(coords, StructureFeature.Feature[feature])
	
	for biome in biomeCoords:
		var list = biomeCoords.get(biome, [])
		var layer = Constant.BiomeToLayer[biome]
		var tile = Constant.BiomeToTile[biome]
		for coordsi in list:
			tilemap.set_cell(layer, coordsi, tile[0], tile[1], tile[2])
			tilemap.set_data(coordsi, Constant.DataKey.Biome, biome)
		#BetterTerrain.set_cells(tilemap, Constant.BiomeToLayer[biome], list, Constant.BiomeToTerrain[biome])
		#BetterTerrain.update_terrain_cells(tilemap, Constant.BiomeToLayer[biome], list)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var mouse := tilemap.get_local_mouse_position()
	var pos := tilemap.local_to_map(mouse)
	
	clear_selection()
	
	highlightedCoords = [pos]
	#highlightedCoords.assign(Hex.hex_ring(Hex.tilemap_to_hex(pos), 2).map(func (hex): return Hex.hex_to_tilemap(hex)))
	add_selection(highlightedCoords)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed:
			if mb.button_index == MOUSE_BUTTON_LEFT:
				on_left_click()
			elif mb.button_index == MOUSE_BUTTON_RIGHT:
				on_right_click()
	if event is InputEventKey:
		var k := event as InputEventKey
		if k.pressed and !k.echo:
			on_key_press(k.physical_keycode)

func on_left_click():
	for coords in highlightedCoords:
		#add_structure(coords, StructureGenerator.Default)
		remove_structure(coords)
		remove_item(coords)

func on_right_click():
	for coords in highlightedCoords:
		var structure: StructureObject = tilemap.get_data(coords, Constant.DataKey.Structure)
		if !structure: continue
		structure.rotateCW()

func on_key_press(key: Key):
	var structure: Structure = structureToAdd.get(key)
	if !structure: return
	for coords in highlightedCoords:
		add_structure(coords, structure)

func loop():
	while true:
		await get_tree().create_timer(secondsPerTick, false).timeout
		step_tick()

func step_tick():
	structures.sort_custom(func (a, b): return a.priority > b.priority)
	tilemap.erase_data_key(Constant.DataKey.Confirmed)
	for structure in structures:
		structure._step_tick()

func clear_selection():
	tilemap.clear_layer(Constant.Layer.Selection)

func push_item(coords: Vector2i, dir: Constant.Direction) -> bool:
	var item: ItemObject = tilemap.get_data(coords, Constant.DataKey.Item)
	var structure: StructureObject = tilemap.get_data(coords, Constant.DataKey.Structure)
	
	var result := false
	if !item: result = true
	else:
		#var dummy = obj.item_dummy
		var nex_dir := dir
		#if obj.type == Type.COMBINER: nex_dir = obj.combiner[1]
		
		var nex_coords := Coords.coords_neighbor(coords, dir)
		if can_enter(nex_coords, nex_dir) and push_item(nex_coords, nex_dir):
			tilemap.erase_data(coords, Constant.DataKey.Item)
			item.coords = nex_coords
			item.set_offset_neg_dir(nex_dir)
			var tween := get_tree().create_tween().bind_node(item)
			tween.tween_property(item, "offset_coords", Vector2.ZERO, secondsPerTick)
			tilemap.set_data(nex_coords, Constant.DataKey.Item, item)
			result = true
		elif item.equals(ItemBubble.Default):
			# pop bubble
			tilemap.erase_data(coords, Constant.DataKey.Item)
			var tween := get_tree().create_tween().bind_node(item)
			tween.tween_property(item, "scale", Vector2.ZERO, 1./4)
			tween.tween_callback(func (): remove_child(item))
			result = true
	
	if result: tilemap.set_data(coords, Constant.DataKey.Confirmed, true)
	return result

func can_enter(coords: Vector2i, dir: Constant.Direction):
	var confirmed: bool = tilemap.get_data(coords, Constant.DataKey.Confirmed, false)
	if confirmed: return false
	
	var biome: Constant.Biome = tilemap.get_data(coords, Constant.DataKey.Biome, Constant.Biome.Water)
	if biome == Constant.Biome.Water: return false
	
	var structure: StructureObject = tilemap.get_data(coords, Constant.DataKey.Structure)
	if !structure: return true
	
	return false

func add_selection(selections: Array[Vector2i]):
	BetterTerrain.set_cells(tilemap, Constant.Layer.Selection, selections, Constant.SelectionTerrain)
	BetterTerrain.update_terrain_cells(tilemap, Constant.Layer.Selection, selections, Constant.SelectionTerrain)
#	tilemap.set_cells_terrain_connect(selectionLayer, selections, selectionTerrainSet, selectionTerrain)

func add_feature(coords: Vector2i, sourceID: int, atlasCoords: Vector2i, alternativeTile: int = 0):
	tilemap.set_cell(Constant.Layer.Feature, coords, sourceID, atlasCoords, alternativeTile)

func add_structure(coords: Vector2i, structure: Structure):
	if tilemap.has_data(coords, Constant.DataKey.Structure) or tilemap.has_data(coords, Constant.DataKey.Item): return
	var obj := structure.create_object()
	obj.coords = coords
	tilemap.add_child(obj)
	tilemap.set_data(coords, Constant.DataKey.Structure, obj)
	structures.append(obj)

func remove_structure(coords: Vector2i):
	var obj: StructureObject = tilemap.get_data(coords, Constant.DataKey.Structure)
	if !obj: return
	tilemap.erase_data(coords, Constant.DataKey.Structure)
	structures.erase(obj)
	obj.queue_free()

func remove_item(coords: Vector2i):
	var obj: ItemObject = tilemap.get_data(coords, Constant.DataKey.Item)
	if !obj: return
	tilemap.erase_data(coords, Constant.DataKey.Item)
	items.erase(obj)
	obj.queue_free()

func add_item(coords: Vector2i, item: Item):
	if tilemap.has_data(coords, Constant.DataKey.Item): return
	var obj := item.create_object()
	obj.coords = coords
	tilemap.add_child(obj)
	tilemap.set_data(coords, Constant.DataKey.Item, obj)
	items.append(obj)
