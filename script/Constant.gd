extends RefCounted
class_name Constant

enum Direction { SE, NE, N, NW, SW, S, None = -1 }

enum Biome {
	Grassland,
	Forest,
	Mountain,
	Water,
	None = -1
}

enum Feature {
	Tree,
	Rock,
	None = -1,
}

const BiomeToColor := {
	Biome.Grassland: Color("#689459"),
	Biome.Forest: Color("#418155"),
	Biome.Mountain: Color("5b5b5b"),
	Biome.Water: Color("54507a")
}

const FeatureToColor := {
	Feature.Tree: Color.DARK_GREEN,
	Feature.Rock: Color.DARK_SLATE_GRAY,
	Feature.None: Color.TRANSPARENT,
}

const ColorToBiome := {
	BiomeToColor[Biome.Grassland]: Biome.Grassland,
	BiomeToColor[Biome.Forest]: Biome.Forest,
	BiomeToColor[Biome.Mountain]: Biome.Mountain,
	BiomeToColor[Biome.Water]: Biome.Water,
}

const BiomeToTerrain := {
	Biome.Grassland: 0,
	Biome.Forest: 1,
	Biome.Mountain: 2,
	Biome.Water: 3,
}

const BiomeToTile := {
	Biome.Grassland: [9, Vector2i.ZERO, 0],
	Biome.Forest: [10, Vector2i.ZERO, 0],
	Biome.Mountain: [11, Vector2i.ZERO, 0],
	Biome.Water: [12, Vector2i.ZERO, 0],
}

const SelectionTerrain := 4

const FeatureToTiles := {
	Feature.Tree: [
		[3, Vector2i.ZERO, 0], 
		[3, Vector2i.ZERO, 1], 
		[3, Vector2i.ZERO, 2], 
		[3, Vector2i.ZERO, 3],
	],
	Feature.Rock: [
		[4, Vector2i.ZERO, 0], 
		[4, Vector2i.ZERO, 1], 
		[4, Vector2i.ZERO, 2], 
		[4, Vector2i.ZERO, 3],
	],
}

const Layer := {
	Water = 0,
	Grassland = 1,
	Mountain = 2,
	Forest = 3,
	Selection = 4,
	Decoration = 5,
	Feature = 6,
}

const BiomeToLayer := {
	Biome.Grassland: Layer.Grassland,
	Biome.Forest: Layer.Forest,
	Biome.Mountain: Layer.Mountain,
	Biome.Water: Layer.Water,
}

const BiomeToTexture := {
	Biome.Grassland: preload("res://asset/new biome/grassland.png"),
	Biome.Forest: preload("res://asset/new biome/forest.png"),
	Biome.Mountain: preload("res://asset/new biome/mountain.png"),
	Biome.Water: preload("res://asset/new biome/water.png"),
}

const DataKey := {
	Visited = &"visited",
	Confirmed = &"confirmed",
	Biome = &"biome",
	Structure = &"structure",
	Item = &"item",
}
