extends RefCounted
class_name Hex

static func hex_add(a: Vector3i, b: Vector3i) -> Vector3i:
	return a + b

static func hex_subtract(a: Vector3i, b: Vector3i) -> Vector3i:
	return a - b

static func hex_multiply(a: Vector3i, k: int) -> Vector3i:
	return a * k

static func hex_length(hex: Vector3i) -> int:
	return int((absi(hex.x) + absi(hex.y) + absi(hex.z)) / 2)

static func hex_distance(a: Vector3i, b: Vector3i) -> int:
	return hex_length(a - b)

static func hex_rotate_left(a: Vector3i) -> Vector3i:
	return Vector3i(-a.z, -a.x, -a.y)

static func hex_rotate_right(a: Vector3i) -> Vector3i:
	return Vector3i(-a.y, -a.z, -a.x)

static func hex_reflect_q(a: Vector3i) -> Vector3i:
	return Vector3i(a.x, a.z, a.y)

static func hex_reflect_r(a: Vector3i) -> Vector3i:
	return Vector3i(a.z, a.y, a.x)

static func hex_reflect_s(a: Vector3i) -> Vector3i:
	return Vector3i(a.y, a.x, a.z)

const hex_directions = [
	Vector3i( 1,  0, -1), Vector3i( 1, -1,  0), Vector3i( 0, -1,  1),
	Vector3i(-1,  0,  1), Vector3i(-1,  1,  0), Vector3i( 0,  1, -1)
]

const hex_diagonals = [
	Vector3i( 2, -1, -1), Vector3i( 1, -2,  1), Vector3i( -1, -1,  2),
	Vector3i(-2,  1,  1), Vector3i(-1,  2, -1), Vector3i(  1,  1, -2)
]

enum FlatDirIdx { SE, NE, N, NW, SW, S }
enum PointyDirIdx { E, NE, NW, W, SW, SE }
enum FlatDiagIdx { E, NE, NW, W, SW, SE }
enum PointyDiagIdx { NE, N, NW, SW, S, SE }

const FlatDir := {
	SE = hex_directions[FlatDirIdx.SE],
	NE = hex_directions[FlatDirIdx.NE],
	N  = hex_directions[FlatDirIdx.N],
	NW = hex_directions[FlatDirIdx.NW],
	SW = hex_directions[FlatDirIdx.SW],
	S  = hex_directions[FlatDirIdx.S],
}

const PointyDir := {
	E  = hex_directions[PointyDirIdx.E],
	NE = hex_directions[PointyDirIdx.NE],
	NW = hex_directions[PointyDirIdx.NW],
	W  = hex_directions[PointyDirIdx.W],
	SW = hex_directions[PointyDirIdx.SW],
	SE = hex_directions[PointyDirIdx.SE],
}

const FlatDiag := {
	E  = hex_directions[FlatDiagIdx.E],
	NE = hex_directions[FlatDiagIdx.NE],
	NW = hex_directions[FlatDiagIdx.NW],
	W  = hex_directions[FlatDiagIdx.W],
	SW = hex_directions[FlatDiagIdx.SW],
	SE = hex_directions[FlatDiagIdx.SE],
}

const PointyDiag := {
	NE = hex_directions[PointyDiagIdx.NE],
	N  = hex_directions[PointyDiagIdx.N],
	NW = hex_directions[PointyDiagIdx.NW],
	SW = hex_directions[PointyDiagIdx.SW],
	S  = hex_directions[PointyDiagIdx.S],
	SE = hex_directions[PointyDiagIdx.SE],
}

static func hex_direction(direction: int) -> Vector3i:
	return hex_directions[(6 + (direction % 6)) % 6]

static func hex_diagonal(diagonal: int) -> Vector3i:
	return hex_diagonals[(6 + (diagonal % 6)) % 6]

static func hex_neighbor(hex: Vector3i, direction: int) -> Vector3i:
	return hex + hex_direction(direction)

static func hex_diagonal_neighbor(hex: Vector3i, diagonal: int) -> Vector3i:
	return hex + hex_diagonal(diagonal)

# Fractional Hex
static func hex_round(h: Vector3) -> Vector3i:
	var q := roundi(h.x)
	var r := roundi(h.y)
	var s := roundi(h.z)
	var q_diff := absf(q - h.x)
	var r_diff := absf(r - h.y)
	var s_diff := absf(s - h.z)
	if (q_diff > r_diff && q_diff > s_diff):
		q = - r - s
	elif r_diff > s_diff:
		r = - q - s
	else:
		s = - q - r
	return Vector3(q, r, s)

static func hex_lerp(a: Vector3, b: Vector3, t: float) -> Vector3:
	return lerp(a, b, t)

# map generation
static func create_map_parallelograms_qr(qSize: int, rSize: int) -> Array[Vector3i]:
	var map: Array[Vector3i] = []
	for q in range(0, qSize):
		for r in range(0, rSize):
			map.push_back(Vector3i(q, r, -q-r))
	return map

static func create_map_parallelograms_rs(rSize: int, sSize: int) -> Array[Vector3i]:
	var map: Array[Vector3i] = []
	for r in range(0, rSize):
		for s in range(0, sSize):
			map.push_back(Vector3i(-r-s, r, s))
	return map

static func create_map_parallelograms_sq(sSize: int, qSize: int) -> Array[Vector3i]:
	var map: Array[Vector3i] = []
	for s in range(0, sSize):
		for q in range(0, qSize):
			map.push_back(Vector3i(q, -s-q, s))
	return map

static func create_map_triangle_SE(size: int) -> Array[Vector3i]:
	var map: Array[Vector3i] = []
	for q in range(0, size):
		for r in range(0, size-q):
			map.push_back(Vector3i(q, r, -q-r))
	return map

static func create_map_triangle_NW(size: int) -> Array[Vector3i]:
	var map: Array[Vector3i] = []
	for q in range(0, size):
		for r in range(size-1-q, size):
			map.push_back(Vector3i(q, r, -q-r))
	return map

static func create_map_hexagon(N: int) -> Array[Vector3i]:
	var map: Array[Vector3i] = []
	for q in range(-N+1, N):
		var r1 := maxi(-N+1, -q - N+1)
		var r2 := mini( N-1, -q + N-1)
		for r in range(r1, r2+1):
			map.push_back(Vector3i(q, r, -q-r))
	return map

static func create_map_rectangle_pointy(offsetType: int, colSize: int, rowSize: int) -> Array[Vector3i]:
	assert(offsetType == OffsetType.EVEN || offsetType == OffsetType.ODD)
	var map: Array[Vector3i] = []
	for col in range(0, colSize):
		for row in range(0, rowSize):
			map.push_back(pointy_offset_to_hex(offsetType, Vector2i(col, row)))
	return map

static func create_map_rectangle_flat(offsetType: int, colSize: int, rowSize: int) -> Array[Vector3i]:
	assert(offsetType == OffsetType.EVEN || offsetType == OffsetType.ODD)
	var map: Array[Vector3i] = []
	for col in range(0, colSize):
		for row in range(0, rowSize):
			map.push_back(flat_offset_to_hex(offsetType, Vector2i(col, row)))
	return map

enum OffsetType { EVEN = 1, ODD = -1 }

# get bunch of hex
static func hex_linedraw(a: Vector3i, b: Vector3i) -> Array[Vector3i]:
	var N := hex_distance(a, b)
	var nudge := Vector3(1e-6, 1e-6, -2e-6)
	var a_nudge := Vector3(a) + nudge
	var b_nudge := Vector3(b) + nudge
	var results: Array[Vector3i] = []
	var step := 1.0 / maxi(N, 1)
	for i in range(N+1):
		results.push_back(hex_round(hex_lerp(a_nudge, b_nudge, step * i)))
	return results

static func hex_range(center: Vector3i, N: int) -> Array[Vector3i]:
	var hexes: Array[Vector3i] = []
	for hex in create_map_hexagon(N+1):
		hexes.push_back(center + hex)
	return hexes

static func hex_ring(center: Vector3i, radius: int) -> Array[Vector3i]:
	if radius <= 0: return [center]
	var results: Array[Vector3i] = []
	var hex = center + hex_direction(0) * radius
	
	for i in range(6):
		for _j in range(radius):
			results.push_back(hex)
			hex = hex_neighbor(hex, i + 2)
	return results

static func hex_spiral(center: Vector3i, radius: int) -> Array[Vector3i]:
	var results: Array[Vector3i] = []
	for k in range(radius+1):
		results.append_array(hex_ring(center, k))
	return results

# conversion
static func hex_to_flat_offset(offsetType: OffsetType, hex: Vector3i) -> Vector2i:
	assert(offsetType == OffsetType.EVEN || offsetType == OffsetType.ODD)
	var col := hex.x
	var row := hex.y + int((hex.x + offsetType * (int(hex.x) & 1)) / 2)
	return Vector2i(col, row)

static func flat_offset_to_hex(offsetType: OffsetType, offset: Vector2i) -> Vector3i:
	assert(offsetType == OffsetType.EVEN || offsetType == OffsetType.ODD)
	var q := offset.x
	var r := offset.y - int((offset.x + offsetType * (offset.x & 1)) / 2)
	var s := - q - r
	return Vector3i(q, r, s)

static func hex_to_pointy_offset(offsetType: OffsetType, hex: Vector3i) -> Vector2i:
	assert(offsetType == OffsetType.EVEN || offsetType == OffsetType.ODD)
	var col := hex.x + int((hex.y + offsetType * (hex.y & 1)) / 2)
	var row := hex.y
	return Vector2i(col, row)

static func pointy_offset_to_hex(offsetType: OffsetType, offset: Vector2i) -> Vector3i:
	assert(offsetType == OffsetType.EVEN || offsetType == OffsetType.ODD)
	var q := offset.x - int((offset.y + offsetType * (offset.y & 1)) / 2)
	var r := offset.y
	var s := - q - r
	return Vector3i(q, r, s)
	
static func tilemap_to_hex(coords: Vector2) -> Vector3:
	return Vector3(coords.x-coords.y, coords.y, -coords.x)

static func hex_to_tilemap(hex: Vector3) -> Vector2:
	return Vector2(-hex.z, hex.y)

# layout conversion

const layout_pointy: Array[float] = [sqrt(3.0), sqrt(3.0) / 2.0, 0.0, 3.0 / 2.0,
					   sqrt(3.0) / 3.0, -1.0 / 3.0, 0.0, 2.0 / 3.0,
					   0.5]
const layout_flat: Array[float] = [3.0 / 2.0, 0.0, sqrt(3.0) / 2.0, sqrt(3.0),
					 2.0 / 3.0, 0.0, -1.0 / 3.0, sqrt(3.0) / 3.0,
					 0.0]

static func get_orientation(is_flat: bool) -> Array[float]:
	if is_flat: return layout_flat
	else: return layout_pointy

static func hex_to_pixel(layout: HexLayout, h: Vector3) -> Vector2:
	var M := get_orientation(layout.is_flat)
	var size := layout.size
	var origin := layout.origin
	var x = (M[0] * h.x + M[1] * h.y) * size.x
	var y = (M[2] * h.x + M[3] * h.y) * size.y
	return Vector2(x + origin.x, y + origin.y)

static func pixel_to_fract_hex(layout: HexLayout, p: Vector2) -> Vector3:
	var M := get_orientation(layout.is_flat)
	var size := layout.size
	var origin := layout.origin
	var pt := Vector2((p.x - origin.x) / size.x, (p.y - origin.y) / size.y)
	var q = M[4] * pt.x + M[5] * pt.y
	var r = M[6] * pt.x + M[7] * pt.y
	return Vector3(q, r, - q - r)

static func pixel_to_hex(layout: HexLayout, p: Vector2) -> Vector3i:
	return Hex.hex_round(pixel_to_fract_hex(layout, p))

static func hex_corner_offset(layout: HexLayout, corner: int) -> Vector2:
	var M := get_orientation(layout.is_flat)
	var size := layout.size
#	var origin := layout.origin
	var angle = 2.0 * PI * (M[8] + corner) / 6
	return Vector2(size.x * cos(angle), size.y * sin(angle))

static func polygon_corners(layout: HexLayout, h: Vector3) -> Array[Vector2]:
	var corners := []
	var center := hex_to_pixel(layout, h)
	for i in range(6):
		var offset := hex_corner_offset(layout, i)
		corners.push_back(center + offset)
	return corners
