extends Node2D
class_name Gameplay

static var I: Gameplay

@onready var secondsPerTick: float = 1.
@onready var holdThreshold: float = .3
@onready var camera: CameraMouseControl = $Camera2D
@onready var tilemap: DataTileMap = $TileMap
@onready var infoPanels: Container = %InfoPanels
const infoPanelPrefab := preload("res://prefab/info_panel/InfoPanel.tscn")

@export var bounding: Rect2i = Rect2i()
@export var initSize: int = 4
@export var mapGenerator: MapGenerator

var leftHoldTimer: Timer
var rightHoldTimer: Timer

var structureToAdd := {
	Key.KEY_L: StructureGatherer.LumberCamp,
	Key.KEY_Q: StructureGatherer.Quarry,
	Key.KEY_D: StructureDestroyer.Default,
	Key.KEY_B: StructureBubbler.Default,
	Key.KEY_X: Structure.Blocker,
	Key.KEY_1: StructureSplitter.Splitter1Way,
	Key.KEY_2: StructureSplitter.Splitter2Way,
	Key.KEY_3: StructureSplitter.Splitter3Way,
	Key.KEY_C: StructureCombiner.Default,
	Key.KEY_O: StructureCrossover.Default,
	Key.KEY_M: StructureMachine.Sawmill,
	Key.KEY_W: StructureMachine.Workshop,
	Key.KEY_G: StructureGenerator.WoodGenerator,
}

var pickedItem: ItemObject

var mouseCoords: Vector2i = Vector2i.ZERO
var highlightedCoords: Array[Vector2i] = []
#var structures: Array[StructureObject] = []
#var items: Array[ItemObject] = []

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
	
	# add initial workshop
	remove_structure(Vector2i.ZERO)
	add_structure(Vector2i.ZERO, StructureMachine.Workshop)
	
	loop()

func generateMap():
	mapGenerator.setup()
	#var origin := Coords.flat_offset_to_coords(Hex.OffsetType.EVEN, bounding.position)
	#var coordss := Coords.create_map_rectangle_flat(Hex.OffsetType.EVEN, bounding.size.x, bounding.size.y)
	#coordss.assign(coordss.map(func (v): return v + origin))
	var coordss := Coords.create_map_hexagon(initSize)
	exploreMaps(coordss)

func exploreMap(coords: Vector2i):
	exploreMaps([coords])

func exploreMaps(coordss: Array[Vector2i]):
	var coordsDict := {}
	var edgeChecks := {}
	var biomeCoords := {}
	for coords in coordss: coordsDict[coords] = true
	for coords in coordss:
		for edge_coords in Coords.coords_ring(coords, 1):
			if !coordsDict.has(edge_coords): edgeChecks[edge_coords] = true
		var uv = Coords.coords_to_pixel(DataTileMap.hex_unit_layout, coords)
		var biome = mapGenerator.f_biome.call(uv.x, uv.y)
		var feature = mapGenerator.f_feature.call(uv.x, uv.y)
		var list = biomeCoords.get(biome, [])
		list.append(coords)
		biomeCoords[biome] = list
		
		if biome != Constant.Biome.Water and feature != Constant.Feature.None:
			add_structure(coords, StructureResource.Feature[feature])
	
	for edge_coords in edgeChecks:
		set_biome(edge_coords, Constant.Biome.Edge)
		var edgeObject := add_structure(edge_coords, StructureEdge.Default)
		var edgeStructure = edgeObject.structure as StructureEdge
		edgeStructure.set_requirements(edgeObject, [Item.ItemWood])
	
	for biome in biomeCoords:
		var list = biomeCoords.get(biome, [])
		var layer = Constant.BiomeToLayer[biome]
		var tile = Constant.BiomeToTile[biome]
		for coordsi in list:
			set_biome(coordsi, biome)
		BetterTerrain.set_cells(tilemap, Constant.BiomeToLayer[biome], list, Constant.BiomeToTerrain[biome])
		BetterTerrain.update_terrain_cells(tilemap, Constant.BiomeToLayer[biome], list)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var mouse := tilemap.get_local_mouse_position()
	var pos := tilemap.local_to_map(mouse)
	
	clear_selection()
	
	mouseCoords = pos
	highlightedCoords = [pos]
	#highlightedCoords.assign(Hex.hex_ring(Hex.tilemap_to_hex(pos), 2).map(func (hex): return Hex.hex_to_tilemap(hex)))
	add_selection(highlightedCoords)
	
	if pickedItem:
		pickedItem.reset_offset()
		pickedItem.set_local_pos(mouse)

func startTimer(time: float, callback: Callable) -> Timer:
	var timer := Timer.new()
	timer.one_shot = true
	timer.timeout.connect(func ():
		timer.queue_free()
		callback.call()
	)
	add_child(timer)
	timer.start(time)
	return timer

func stopTimer(timer: Timer):
	if !timer: return
	timer.stop()
	timer.queue_free()

func _unhandled_input(event):
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				stopTimer(leftHoldTimer)
				leftHoldTimer = startTimer(holdThreshold, func ():
					leftHoldTimer = null
					on_left_hold()
				)
			else:
				if leftHoldTimer:
					on_left_click()
					stopTimer(leftHoldTimer)
					leftHoldTimer = null
		elif mb.button_index == MOUSE_BUTTON_RIGHT:
			if mb.pressed:
				stopTimer(rightHoldTimer)
				rightHoldTimer = startTimer(holdThreshold, func ():
					rightHoldTimer = null
					on_right_hold()
				)
			else:
				if rightHoldTimer:
					on_right_click()
					stopTimer(rightHoldTimer)
					rightHoldTimer = null
	if event is InputEventKey:
		var k := event as InputEventKey
		if k.pressed and !k.echo:
			on_key_press(k.physical_keycode)

func on_left_click():
	#add_structure(coords, StructureGenerator.Default)
	#remove_structure(coords)
	#remove_item(coords)
	select_cell(mouseCoords)
	var structure := get_structure(mouseCoords)
	swap_item(mouseCoords)
	if pickedItem and pickedItem.equals(ItemBubble.Default):
		pickedItem.delete(true)
		pickedItem = null
	if structure:
		structure._on_left_click()

func on_left_hold():
	var structure := get_structure(mouseCoords)
	if structure:
		pick_item(mouseCoords)
		structure.pack_structure()
		swap_item(mouseCoords)
		var item := get_item(mouseCoords)
		if item: item.build_structure()
	else:
		var item := get_item(mouseCoords)
		if !item:
			swap_item(mouseCoords)
			item = get_item(mouseCoords)
			if item: item.build_structure()
		else:
			if !item.build_structure():
				swap_item(mouseCoords)
				item = get_item(mouseCoords)
				if item: item.build_structure()
	
	if pickedItem and pickedItem.equals(ItemBubble.Default):
		pickedItem.delete(true)
		pickedItem = null

func on_right_click():
	var structure := get_structure(mouseCoords)
	if structure:
		structure.rotateCCW()
		structure._on_right_click()

func on_right_hold():
	pass

func on_key_press(key: Key):
	var structure: Structure = structureToAdd.get(key)
	if !structure: return
	add_structure(mouseCoords, structure, true)

func loop():
	while true:
		await get_tree().create_timer(secondsPerTick, false).timeout
		step_tick()

func step_tick():
	var structures := get_all_structures()
	structures.sort_custom(func (a, b):
		if !b.structure: return true
		if !a.structure: return false
		var a_structure_priority = a.structure.get_priority()
		var b_structure_priority = b.structure.get_priority()
		if a_structure_priority != b_structure_priority: return a_structure_priority > b_structure_priority
		else: return a.priority > b.priority
	)
	tilemap.erase_data_layer(Constant.DataKey.Visited)
	tilemap.erase_data_layer(Constant.DataKey.Confirmed)
	for structure in structures:
		structure._step_tick()

func clear_selection():
	tilemap.clear_layer(Constant.Layer.Selection)
	
func push_item_from(coords: Vector2i, output_dir: Constant.Direction) -> bool:
	var item: ItemObject = get_item(coords)
	var structure: StructureObject = get_structure(coords)
	
	var result := false
	if !item: result = true
	else:
		var nex_coords := Coords.coords_neighbor(coords, output_dir)
		
		if push_item_to(item, nex_coords, output_dir):
			tilemap.erase_data(coords, Constant.DataKey.Item)
			if structure: structure._on_item_exit(item, output_dir)
			result = true
		elif item.equals(ItemBubble.Default):
			# pop bubble
			remove_item(item.coordsi, true)
			result = true
	
	return result

func push_item_to(item: ItemObject, coords: Vector2i, input_dir: Constant.Direction) -> bool:
	if !can_enter(coords, input_dir): return false
	var structure: StructureObject = get_structure(coords)
	
	tilemap.set_data(coords, Constant.DataKey.Visited, true)
	var result := false
	
	if structure:
		result = structure.push_item_to(item, input_dir)
	else:
		result = push_item_from(coords, input_dir)
	
	tilemap.set_data(coords, Constant.DataKey.Visited, false)
	
	if result:
		tilemap.set_data(coords, Constant.DataKey.Item, item)
		if item:
			#item.coords = coords
			item.set_coords_keep_position(coords)
			item.reset_offset(true)
			tilemap.set_data(coords, Constant.DataKey.Confirmed, true)
		if structure: structure._on_item_enter(item, input_dir)
	
	return result

func can_enter(coords: Vector2i, input_dir: Constant.Direction):
	var visited: bool = tilemap.get_data(coords, Constant.DataKey.Visited, false)
	var confirmed: bool = tilemap.get_data(coords, Constant.DataKey.Confirmed, false)
	var structure: StructureObject = get_structure(coords)
	
	if !structure or !structure.can_accept_multiple():
		if confirmed or visited: return false
	
	var biome = get_biome(coords)
	if biome == Constant.Biome.Water or biome == Constant.Biome.None: return false
	
	if structure: return structure.can_enter(input_dir)
	
	return true

func add_selection(selections: Array[Vector2i]):
	BetterTerrain.set_cells(tilemap, Constant.Layer.Selection, selections, Constant.SelectionTerrain)
	BetterTerrain.update_terrain_cells(tilemap, Constant.Layer.Selection, selections, Constant.SelectionTerrain)
#	tilemap.set_cells_terrain_connect(selectionLayer, selections, selectionTerrainSet, selectionTerrain)

func add_feature(coords: Vector2i, sourceID: int, atlasCoords: Vector2i, alternativeTile: int = 0):
	tilemap.set_cell(Constant.Layer.Feature, coords, sourceID, atlasCoords, alternativeTile)

func get_biome(coordsi: Vector2i) -> Constant.Biome:
	return tilemap.get_data(coordsi, Constant.DataKey.Biome, Constant.Biome.None)

func get_all_structures() -> Array[StructureObject]:
	var result: Array[StructureObject] = []
	result.assign(tilemap.get_data_layer(Constant.DataKey.Structure).values())
	return result

func get_all_items() -> Array[ItemObject]:
	var result: Array[ItemObject] = []
	result.assign(tilemap.get_data_layer(Constant.DataKey.Item).values())
	return result

func get_structure(coordsi: Vector2i) -> StructureObject:
	return tilemap.get_data(coordsi, Constant.DataKey.Structure)

func get_item(coordsi: Vector2i) -> ItemObject:
	return tilemap.get_data(coordsi, Constant.DataKey.Item)

func set_biome(coordsi: Vector2i, biome: Constant.Biome):
	return tilemap.set_data(coordsi, Constant.DataKey.Biome, biome)

func set_structure(coordsi: Vector2i, obj: StructureObject):
	return tilemap.set_data(coordsi, Constant.DataKey.Structure, obj)

func set_item(coordsi: Vector2i, obj: ItemObject):
	return tilemap.set_data(coordsi, Constant.DataKey.Item, obj)

func pick_item(coordsi: Vector2i) -> bool:
	if pickedItem: return false
	pickedItem = get_item(coordsi)
	set_item(coordsi, null)
	return true

func drop_item(coordsi: Vector2i) -> bool:
	if !pickedItem: return true
	if !can_add_item(coordsi): return false
	pickedItem.coordsi = coordsi
	set_item(coordsi, pickedItem)
	pickedItem = null
	return true

func swap_item(coordsi: Vector2i) -> bool:
	var tileItem = get_item(coordsi)
	set_item(coordsi, null)
	
	if drop_item(coordsi):
		pickedItem = tileItem
		return true
	else:
		# balikin
		set_item(coordsi, tileItem)
		return false

func add_structure(coords: Vector2i, structure: Structure, animate: bool = false) -> StructureObject:
	if get_structure(coords): return null
	if !structure.is_flat() and get_item(coords): return null
	var obj := structure.create_object()
	obj.coords = coords
	tilemap.add_child(obj)
	tilemap.set_data(coords, Constant.DataKey.Structure, obj)
	#structures.append(obj)
	if animate:
		var tween := obj.create_tween().bind_node(obj)
		tween.tween_property(obj, "scale", Vector2.ONE, 1./4).from(Vector2.ZERO)
	return obj

func add_item(coords: Vector2i, item: Item, animate: bool = false) -> ItemObject:
	if get_item(coords): return null
	var obj := item.create_object()
	obj.coords = coords
	tilemap.add_child(obj)
	tilemap.set_data(coords, Constant.DataKey.Item, obj)
	#items.append(obj)
	if animate:
		var tween := obj.create_tween().bind_node(obj)
		tween.tween_property(obj, "scale", Vector2.ONE, 1./4).from(Vector2.ZERO)
	return obj

func can_add_item(coords: Vector2i) -> bool:
	var item := get_item(coords)
	var structure := get_structure(coords)
	var biome := get_biome(coords)
	if item: return false
	if biome == Constant.Biome.Water or biome == Constant.Biome.None: return false
	if structure and !structure.is_flat(): return false
	return true

func remove_structure(coords: Vector2i, animate: bool = false):
	var obj: StructureObject = get_structure(coords)
	if !obj: return
	obj.delete(animate)

func remove_item(coords: Vector2i, animate: bool = false):
	var obj: ItemObject = get_item(coords)
	if !obj: return
	obj.delete(animate)

func select_cell(coords: Vector2i):
	var biome: Constant.Biome = tilemap.get_data(coords, Constant.DataKey.Biome, -1)
	var structure: StructureObject = tilemap.get_data(coords, Constant.DataKey.Structure)
	var item: ItemObject = tilemap.get_data(coords, Constant.DataKey.Item)
	
	for child in infoPanels.get_children():
		child.queue_free() # just destroy for now
	
	#if item:
		#var infoPanel: InfoPanel = infoPanelPrefab.instantiate()
		#infoPanels.add_child(infoPanel)
		#infoPanel.sprite.texture = item.item.texture
		#infoPanel.categoryLabel.text = "Item"
		#infoPanel.titleLabel.text = item.item.name
		
	if structure:
		var infoPanel: InfoPanel = structure.create_info()
		infoPanels.add_child(infoPanel)
		#infoPanel.sprite.texture = structure.structure.texture
		#infoPanel.categoryLabel.text = "Structure"
		#infoPanel.titleLabel.text = structure.structure.name
		
	#if biome != -1:
		#var infoPanel: InfoPanel = infoPanelPrefab.instantiate()
		#infoPanels.add_child(infoPanel)
		#infoPanel.sprite.texture = Constant.BiomeToTexture[biome]
		#infoPanel.categoryLabel.text = "Biome"
		#infoPanel.titleLabel.text = Constant.Biome.keys()[biome]
	
