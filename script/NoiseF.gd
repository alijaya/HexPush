extends RefCounted
class_name NoiseF

enum ColorChannel { R, G, B, A, L }

static func create_image_rgb(f_rgb: Callable, width: int, height: int) -> Image:
	var data := PackedByteArray()
	for j in range(height):
		for i in range(width):
			var c: Color = f_rgb.call(i, j)
			data.append(c.r8)
			data.append(c.g8)
			data.append(c.b8)
	return Image.create_from_data(width, height, false, Image.FORMAT_RGB8, data)

static func create_image(f: Callable, width: int, height: int, normalize: bool = true) -> Image:
	var data := PackedByteArray()
	for j in range(height):
		for i in range(width):
			var v: float = f.call(i, j)
			if normalize: v = remap(v, -1, 1, 0, 1)
			data.append(v * 255)
	return Image.create_from_data(width, height, false, Image.FORMAT_L8, data)

static func from_image(image: Image, color_channel: ColorChannel = ColorChannel.L) -> Callable:
	return func (x: float, y: float):
		var color := image.get_pixel(fposmod(x, image.get_width()), fposmod(y, image.get_height()))
		match color_channel:
			ColorChannel.R: return color.r
			ColorChannel.G: return color.g
			ColorChannel.B: return color.b
			ColorChannel.A: return color.a
			ColorChannel.L: return color.get_luminance()
			_: return color.get_luminance()

static func from_texture(texture: Texture2D, color_channel: ColorChannel = ColorChannel.L) -> Callable:
	return from_image(texture.get_image(), color_channel)

static func from_array_texture(arrayTexture: ArrayTexture2D, index: int, color_channel: ColorChannel = ColorChannel.L) -> Callable:
	return from_image(arrayTexture.array[index].get_image(), color_channel)

static func from_random_array_texture(arrayTexture: ArrayTexture2D, color_channel: ColorChannel = ColorChannel.L) -> Callable:
	var image: Image = arrayTexture.array.pick_random().get_image()
	return f_offset(from_image(image, color_channel), randf_range(0, image.get_width()), randf_range(0, image.get_height()))

static func from_noise(noise: FastNoiseLite, normalize: bool = true) -> Callable:
	var f: Callable = func (x: float, y: float): return noise.get_noise_2d.call(x, y)
	if !normalize: return f
	else: return f_normalize(f)

static func from_seed_noise(noise: FastNoiseLite, seed: int, normalize: bool = true) -> Callable:
	var new_noise: FastNoiseLite = noise.duplicate()
	new_noise.seed = seed
	return from_noise(new_noise, normalize)

static func from_random_noise(noise: FastNoiseLite, normalize: bool = true) -> Callable:
	return from_seed_noise(noise, randi(), normalize)

static func f_invert(f: Callable) -> Callable:
	return func (x: float, y: float):
		return -f.call(x, y)

static func f_reciprocal(f: Callable) -> Callable:
	return func (x: float, y: float):
		return 1./f.call(x, y)

static func f_add(f: Callable, v: float) -> Callable:
	return func (x: float, y: float):
		return f.call(x, y) + v

static func f_sub(f: Callable, v: float) -> Callable:
	return f_add(f, -v)

static func f_mul(f: Callable, v: float) -> Callable:
	return func (x: float, y: float):
		return f.call(x, y) * v

static func f_div(f: Callable, v: float) -> Callable:
	return f_mul(f, 1./v)

static func f_modified_pow(f: Callable, v: float) -> Callable:
	return func (x: float, y: float):
		var t: float = f.call(x, y)
		if t >= 0: return pow(t, pow(2, v))
		else: return -pow(-t, pow(2, v))

static func f_abs(f: Callable) -> Callable:
	return func (x: float, y: float):
		return absf(f.call(x, y))

static func f_mod(f: Callable, v: float) -> Callable:
	return func (x: float, y: float):
		return fposmod(f.call(x, y), v)

static func f_clamp(f: Callable, min: float, max: float) -> Callable:
	return func (x: float, y: float):
		return clampf(f.call(x, y), min, max)

static func f_lerp(from: Callable, to: Callable, weight: float) -> Callable:
	return func (x: float, y: float):
		return lerpf(from.call(x, y), to.call(x, y), weight)

static func f_add_f(a: Callable, b: Callable) -> Callable:
	return func (x: float, y: float):
		return a.call(x, y) + b.call(x, y)

static func f_sub_f(a: Callable, b: Callable) -> Callable:
	return func (x: float, y: float):
		return a.call(x, y) - b.call(x, y)

static func f_mul_f(a: Callable, b: Callable) -> Callable:
	return func (x: float, y: float):
		return a.call(x, y) * b.call(x, y)

static func f_div_f(a: Callable, b: Callable) -> Callable:
	return func (x: float, y: float):
		return a.call(x, y) / b.call(x, y)

static func f_threshold(f: Callable, v: float) -> Callable:
	return func (x: float, y: float):
		return 0. if f.call(x, y) < v else 1.

static func f_posterize(f: Callable, v: float) -> Callable:
	return func (x: float, y: float):
		return floorf(f.call(x, y) / v) * v

static func f_normalize(f: Callable) -> Callable:
	return func (x: float, y: float):
		return f.call(x, y) / 2. + 0.5

static func f_unnormalize(f: Callable) -> Callable:
	return func (x: float, y: float):
		return (f.call(x, y) - 0.5) * 2

static func f_remap(f: Callable, istart: float, istop: float, ostart: float, ostop: float) -> Callable:
	return func (x: float, y: float):
		return remap(f.call(x, y), istart, istop, ostart, ostop)

static func f_transform(f: Callable, t: Callable):
	return func (x: float, y: float):
		return t.call(f.call(x, y))

static func f_offset(f: Callable, x_offset: float, y_offset: float) -> Callable:
	return func (x: float, y: float):
		return f.call(x - x_offset, y - y_offset)

static func f_scale(f: Callable, x_scale: float, y_scale: float) -> Callable:
	return func (x: float, y: float):
		return f.call(x / x_scale, y / y_scale)

static func f_displace(f: Callable, d: Callable) -> Callable:
	return func (x: float, y: float):
		var d_vec: Vector2 = d.call(x, y)
		return f.call(d_vec.x, d_vec.y)
		
const dirs: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1), Vector2i(-1, 1),
							Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1)]

static func f_radial(f: Callable, radius: float, threshold: float = 0.) -> Callable:
	return func (x: float, y: float):
		x = x / radius
		y = y / radius
		var cell := Vector2i(x, y)
		var cellPos := Vector2(x + 0.5, y + 0.5)
		
		# check center + 8 direction
		var cur := 0.
		for dir in dirs:
			var nexCell := cell + dir
			if f.call(nexCell.x, nexCell.y) > threshold:
				var nexCellPos := Vector2(nexCell.x + 0.5, nexCell.y + 0.5)
				var val := clampf(remap(cellPos.distance_to(nexCellPos), 0, 1, 1, 0), 0, 1)
				cur = cur + val
		return clamp(cur, 0, 1)

static func f_fractal(f: Callable, is_normalized: bool = true, octaves: int = 5, lacunarity: float = 2., gain: float = 0.5):
	return func (x: float, y: float):
		var total := .0
		var total_gain := .0
		for oct in octaves:
			var cur_gain := pow(gain, oct)
			total_gain += cur_gain
			var cur_lacunarity := pow(lacunarity, oct)
			var val: float = f.call(x * cur_lacunarity, y * cur_lacunarity)
			if is_normalized: val = (val - 0.5) * 2
			total += val * cur_gain
		total /= total_gain
		if is_normalized: total = total / 2 + 0.5
		return total
