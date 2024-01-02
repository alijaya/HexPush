extends Node2D

@export var mapGenerator: MapGenerator
@onready var sprite: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	mapGenerator.setup()
	var f_feature := mapGenerator.f_feature
	var f_biome := mapGenerator.f_biome
	
	var f_rgb := func (x: float, y: float):
		var feature = f_feature.call(x, y)
		var biome = f_biome.call(x, y)
		if feature != Constant.Feature.None and biome != Constant.Biome.Water:
			return Constant.FeatureToColor[feature]
		else: return Constant.BiomeToColor[biome]
	
	var image := NoiseF.create_image_rgb(f_rgb, 80, 45)
	sprite.texture = ImageTexture.create_from_image(image)
	sprite.scale = Vector2.ONE * 24
