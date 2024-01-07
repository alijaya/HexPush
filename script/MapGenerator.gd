extends Resource
class_name MapGenerator

@export var seed: int = 0
@export var noise: Noise
@export var colorMap: Texture2D
@export var blueNoises: ArrayTexture2D
@export var minElevation: float = -.8
@export var maxElevation: float = 1.8
@export var gainElevation: float = 1
@export var minMoisture: float = .2
@export var maxMoisture: float = 1.2
@export var gainMoisture: float = 1.
@export var minRockProbs: float = -.3
@export var maxRockProbs: float = .6
@export var minTreeProbs: float = -1.
@export var maxTreeProbs: float = 1.
@export var ironProbs: float = .05
@export var coalProbs: float = .05
var colorImage: Image

var f_elevation: Callable
var f_moisture: Callable
var f_tree_blue_noise: Callable
var f_rock_blue_noise: Callable
var f_coal_blue_noise: Callable
var f_iron_blue_noise: Callable
var f_tree_probs: Callable
var f_rock_probs: Callable
var f_biome: Callable
var f_feature: Callable

func setup():
	seed(seed)
	colorImage = colorMap.get_image()
	f_elevation = NoiseF.f_modified_pow(NoiseF.f_remap(NoiseF.from_random_noise(noise), 0, 1, minElevation, maxElevation), pow(2, -gainElevation))
#	var f_poles := func (_x: float, y: float):
#		return 1 - sin(PI * y / 45)
#	var f_ee := NoiseF.f_add_f(f_elevation, NoiseF.f_mul(f_poles, 0.7))
	f_moisture = NoiseF.f_modified_pow(NoiseF.f_remap(NoiseF.from_random_noise(noise), 0, 1, minMoisture, maxMoisture), pow(2, -gainMoisture))
	
	f_tree_blue_noise = NoiseF.from_random_array_texture(blueNoises)
	f_rock_blue_noise = NoiseF.from_random_array_texture(blueNoises)
	f_coal_blue_noise = NoiseF.from_random_array_texture(blueNoises)
	f_iron_blue_noise = NoiseF.from_random_array_texture(blueNoises)
	f_tree_probs = NoiseF.f_remap(f_moisture, 0, 1, minTreeProbs, maxTreeProbs)
	f_rock_probs = NoiseF.f_remap(f_elevation, 0, 1, minRockProbs, maxRockProbs)
	
	f_biome = func (x: float, y: float):
		var elevation: float = f_elevation.call(x, y)
		var moisture: float = f_moisture.call(x, y)
		var biome = get_biome(elevation, moisture)
		
		return biome
	
	f_feature = func (x: float, y: float):
		var tree_blue_noise: float = f_tree_blue_noise.call(x, y)
		var tree_probs: float = f_tree_probs.call(x, y)
		var tree: bool = tree_blue_noise < tree_probs
		var rock_blue_noise: float = f_rock_blue_noise.call(x, y)
		var rock_probs: float = f_rock_probs.call(x, y)
		var rock: bool = rock_blue_noise < rock_probs
		var coal_blue_noise: float = f_coal_blue_noise.call(x, y)
		var coal: bool = coal_blue_noise < coalProbs
		var iron_blue_noise: float = f_iron_blue_noise.call(x, y)
		var iron: bool = iron_blue_noise < ironProbs
		
		var treeOrCoal := Constant.Feature.CoalNode if iron else Constant.Feature.Tree
		var rockOrIron := Constant.Feature.IronNode if iron else Constant.Feature.Rock
		
		if rock and tree:
			if rock_probs > tree_probs: return rockOrIron
			else: return treeOrCoal
		elif rock: return rockOrIron
		elif tree: return treeOrCoal
		else: return Constant.Feature.None

func get_biome(elevation: float, moisture: float) -> Constant.Biome:
	var x := clampi(moisture * 255, 0, 255)
	var y := clampi((1-elevation) * 255, 0, 255)
	if elevation < 0: return Constant.Biome.Water
	else: return Constant.ColorToBiome[colorImage.get_pixel(x, y)]
