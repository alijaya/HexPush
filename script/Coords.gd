extends RefCounted
class_name Coords

static func coords_to_hex(coords: Vector2) -> Vector3:
	return Vector3(coords.x-coords.y, coords.y, -coords.x)

static func hex_to_coords(hex: Vector3) -> Vector2:
	return Vector2(-hex.z, hex.y)

static func array_hex_to_coords(arr: Array[Vector3i]) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	result.assign(arr.map(func(v): return hex_to_coords(v)))
	return result

static func array_coords_to_hex(arr: Array[Vector2i]) -> Array[Vector3i]:
	var result: Array[Vector3i] = []
	result.assign(arr.map(func(v): return coords_to_hex(v)))
	return result

static func coords_add(a: Vector2i, b: Vector2i) -> Vector2i:
	return a + b

static func coords_subtract(a: Vector2i, b: Vector2i) -> Vector2i:
	return a - b

static func coords_multiply(a: Vector2i, k: int) -> Vector2i:
	return a * k

static func coords_length(coords: Vector2i) -> int:
	return Hex.hex_length(coords_to_hex(coords))

static func coords_distance(a: Vector2i, b: Vector2i) -> int:
	return Hex.hex_distance(coords_to_hex(a), coords_to_hex(b))

static func coords_rotate_left(a: Vector2i) -> Vector2i:
	return hex_to_coords(Hex.hex_rotate_left(coords_to_hex(a)))

static func coords_rotate_ccw(a: Vector2i) -> Vector2i:
	return hex_to_coords(Hex.hex_rotate_ccw(coords_to_hex(a)))

static func coords_rotate_right(a: Vector2i) -> Vector2i:
	return hex_to_coords(Hex.hex_rotate_right(coords_to_hex(a)))

static func coords_rotate_cw(a: Vector2i) -> Vector2i:
	return hex_to_coords(Hex.hex_rotate_cw(coords_to_hex(a)))

static func coords_reflect_q(a: Vector2i) -> Vector2i:
	return hex_to_coords(Hex.hex_reflect_q(coords_to_hex(a)))

static func coords_reflect_r(a: Vector2i) -> Vector2i:
	return hex_to_coords(Hex.hex_reflect_r(coords_to_hex(a)))

static func coords_reflect_s(a: Vector2i) -> Vector2i:
	return hex_to_coords(Hex.hex_reflect_s(coords_to_hex(a)))

static func coords_direction(direction: int) -> Vector2i:
	return hex_to_coords(Hex.hex_direction(direction))

static func coords_diagonal(diagonal: int) -> Vector2i:
	return hex_to_coords(Hex.hex_diagonal(diagonal))

static func coords_neighbor(coords: Vector2i, direction: int) -> Vector2i:
	return hex_to_coords(Hex.hex_neighbor(coords_to_hex(coords), direction))

static func coords_diagonal_neighbor(coords: Vector2i, diagonal: int) -> Vector2i:
	return hex_to_coords(Hex.hex_diagonal_neighbor(coords_to_hex(coords), diagonal))

# Fractional Coords
static func coords_round(coords: Vector2) -> Vector2i:
	return hex_to_coords(Hex.hex_round(coords_to_hex(coords)))

static func hex_lerp(a: Vector2, b: Vector2, t: float) -> Vector2:
	return lerp(a, b, t)

# map generation

static func create_map_parallelograms_qr(qSize: int, rSize: int) -> Array[Vector2i]:
	return array_hex_to_coords(Hex.create_map_parallelograms_qr(qSize, rSize))

static func create_map_parallelograms_rs(rSize: int, sSize: int) -> Array[Vector2i]:
	return array_hex_to_coords(Hex.create_map_parallelograms_rs(rSize, sSize))

static func create_map_parallelograms_sq(sSize: int, qSize: int) -> Array[Vector2i]:
	return array_hex_to_coords(Hex.create_map_parallelograms_sq(sSize, qSize))

static func create_map_triangle_SE(size: int) -> Array[Vector2i]:
	return array_hex_to_coords(Hex.create_map_triangle_SE(size))

static func create_map_triangle_NW(size: int) -> Array[Vector2i]:
	return array_hex_to_coords(Hex.create_map_triangle_NW(size))

static func create_map_hexagon(N: int) -> Array[Vector2i]:
	return array_hex_to_coords(Hex.create_map_hexagon(N))

static func create_map_rectangle_pointy(offsetType: int, colSize: int, rowSize: int) -> Array[Vector2i]:
	return array_hex_to_coords(Hex.create_map_rectangle_pointy(offsetType, colSize, rowSize))

static func create_map_rectangle_flat(offsetType: int, colSize: int, rowSize: int) -> Array[Vector2i]:
	return array_hex_to_coords(Hex.create_map_rectangle_flat(offsetType, colSize, rowSize))

# get bunch of hex
static func coords_linedraw(a: Vector2i, b: Vector2i) -> Array[Vector2i]:
	return array_hex_to_coords(Hex.hex_linedraw(coords_to_hex(a), coords_to_hex(b)))

static func coords_range(center: Vector2i, N: int) -> Array[Vector2i]:
	return array_hex_to_coords(Hex.hex_range(coords_to_hex(center), N))

static func coords_ring(center: Vector2i, radius: int) -> Array[Vector2i]:
	return array_hex_to_coords(Hex.hex_ring(coords_to_hex(center), radius))

static func coords_spiral(center: Vector2i, radius: int) -> Array[Vector2i]:
	return array_hex_to_coords(Hex.hex_spiral(coords_to_hex(center), radius))

# conversion
static func coords_to_flat_offset(offsetType: Hex.OffsetType, coords: Vector2i) -> Vector2i:
	return Hex.hex_to_flat_offset(offsetType, coords_to_hex(coords))

static func flat_offset_to_coords(offsetType: Hex.OffsetType, offset: Vector2i) -> Vector2i:
	return hex_to_coords(Hex.flat_offset_to_hex(offsetType, offset))

static func coords_to_pointy_offset(offsetType: Hex.OffsetType, coords: Vector2i) -> Vector2i:
	return Hex.hex_to_pointy_offset(offsetType, coords_to_hex(coords))

static func pointy_offset_to_coords(offsetType: Hex.OffsetType, offset: Vector2i) -> Vector2i:
	return hex_to_coords(Hex.pointy_offset_to_hex(offsetType, offset))

# layout conversion
static func coords_to_pixel(layout: HexLayout, coords: Vector2) -> Vector2:
	return Hex.hex_to_pixel(layout, coords_to_hex(coords))

static func pixel_to_fract_coords(layout: HexLayout, p: Vector2) -> Vector2:
	return hex_to_coords(Hex.pixel_to_fract_hex(layout, p))

static func pixel_to_coords(layout: HexLayout, p: Vector2) -> Vector2i:
	return hex_to_coords(Hex.pixel_to_hex(layout, p))

static func polygon_corners(layout: HexLayout, coords: Vector2i) -> Array[Vector2]:
	return Hex.polygon_corners(layout, coords_to_hex(coords))
