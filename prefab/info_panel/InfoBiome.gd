extends InfoPanel
class_name InfoBiome

@export var biome: Constant.Biome

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	categoryLabel.text = "Biome"
	if biome != Constant.Biome.None:
		sprite.texture = Constant.BiomeToTexture[biome]
		titleLabel.text = Constant.Biome.keys()[biome]
