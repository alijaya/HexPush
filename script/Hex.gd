extends Reference
class_name Hex

static func hex_add(a: Vector3, b: Vector3) -> Vector3:
	return a + b

static func hex_subtract(a: Vector3, b: Vector3) -> Vector3:
	return a - b

static func hex_multiply(a: Vector3, k: int) -> Vector3:
	return a * k

static func hex_length(hex: Vector3) -> int:
	return int((abs(hex.x) + abs(hex.y) + abs(hex.z)) / 2)

static func hex_distance(a: Vector3, b: Vector3) -> int:
	return hex_length(a - b)

static func hex_rotate_left(a: Vector3) -> Vector3:
	return Vector3(-a.z, -a.x, -a.y)

static func hex_rotate_right(a: Vector3) -> Vector3:
	return Vector3(-a.y, -a.z, -a.x)

static func hex_reflect_q(a: Vector3) -> Vector3:
	return Vector3(a.x, a.z, a.y)

static func hex_reflect_r(a: Vector3) -> Vector3:
	return Vector3(a.z, a.y, a.x)

static func hex_reflect_s(a: Vector3) -> Vector3:
	return Vector3(a.y, a.x, a.z)

const hex_directions = [
	Vector3( 1,  0, -1), Vector3( 1, -1,  0), Vector3( 0, -1,  1),
	Vector3(-1,  0,  1), Vector3(-1,  1,  0), Vector3( 0,  1, -1)
]

const hex_diagonals = [
	Vector3( 2, -1, -1), Vector3( 1, -2,  1), Vector3( -1, -1,  2),
	Vector3(-2,  1,  1), Vector3(-1,  2, -1), Vector3(  1,  1, -2)
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

static func hex_direction(direction: int) -> Vector3:
	return hex_directions[(6 + (direction % 6)) % 6]

static func hex_diagonal(diagonal: int) -> Vector3:
	return hex_diagonals[(6 + (diagonal % 6)) % 6]

static func hex_neighbor(hex: Vector3, direction: int) -> Vector3:
	return hex + hex_direction(direction)

static func hex_diagonal_neighbor(hex: Vector3, diagonal: int) -> Vector3:
	return hex + hex_diagonal(diagonal)

# Fractional Hex
static func hex_round(h: Vector3) -> Vector3:
	var q := round(h.x)
	var r := round(h.y)
	var s := round(h.z)
	var q_diff := abs(q - h.x)
	var r_diff := abs(r - h.y)
	var s_diff := abs(s - h.z)
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
static func create_map_parallelograms_qr(qSize: int, rSize: int) -> Array: #Vector3
	var map := []
	for q in range(0, qSize):
		for r in range(0, rSize):
			map.push_back(Vector3(q, r, -q-r))
	return map

static func create_map_parallelograms_rs(rSize: int, sSize: int) -> Array: #Vector3
	var map := []
	for r in range(0, rSize):
		for s in range(0, sSize):
			map.push_back(Vector3(-r-s, r, s))
	return map

static func create_map_parallelograms_sq(sSize: int, qSize: int) -> Array: #Vector3
	var map := []
	for s in range(0, sSize):
		for q in range(0, qSize):
			map.push_back(Vector3(q, -s-q, s))
	return map

static func create_map_triangle_SE(size: int) -> Array: #Vector3
	var map := []
	for q in range(0, size):
		for r in range(0, size-q):
			map.push_back(Vector3(q, r, -q-r))
	return map

static func create_map_triangle_NW(size: int) -> Array: #Vector3
	var map := []
	for q in range(0, size):
		for r in range(size-1-q, size):
			map.push_back(Vector3(q, r, -q-r))
	return map

static func create_map_hexagon(N: int) -> Array: #Vector3
	var map := []
	for q in range(-N+1, N):
		var r1 := max(-N+1, -q - N+1)
		var r2 := min( N-1, -q + N-1)
		for r in range(r1, r2+1):
			map.push_back(Vector3(q, r, -q-r))
	return map

static func create_map_rectangle_pointy(offsetType: int, colSize: int, rowSize: int) -> Array: #Vector3
	assert(offsetType == OffsetType.EVEN || offsetType == OffsetType.ODD)
	var map := []
	for col in range(0, colSize):
		for row in range(0, rowSize):
			map.push_back(pointyOffset2hex(offsetType, Vector2(col, row)))
	return map

static func create_map_rectangle_flat(offsetType: int, colSize: int, rowSize: int) -> Array: #Vector3
	assert(offsetType == OffsetType.EVEN || offsetType == OffsetType.ODD)
	var map := []
	for col in range(0, colSize):
		for row in range(0, rowSize):
			map.push_back(flatOffset2hex(offsetType, Vector2(col, row)))
	return map

enum OffsetType { EVEN = 1, ODD = -1 }

# get bunch of hex
static func hex_linedraw(a: Vector3, b: Vector3) -> Array: #Vector3
	var N := hex_distance(a, b)
	var nudge := Vector3(1e-6, 1e-6, -2e-6)
	var a_nudge := a + nudge
	var b_nudge := b + nudge
	var results := []
	var step := 1.0 / max(N, 1)
	for i in range(N+1):
		results.push_back(hex_round(hex_lerp(a_nudge, b_nudge, step * i)))
	return results

static func hex_range(center: Vector3, N: int) -> Array: #Vector3
	var hexes := []
	for hex in create_map_hexagon(N+1):
		hexes.push_back(center + hex)
	return hexes

static func hex_ring(center: Vector3, radius: int) -> Array: #Vector3
	if radius <= 0: return [center]
	var results := []
	var hex = center + hex_direction(0) * radius
	
	for i in range(6):
		for _j in range(radius):
			results.push_back(hex)
			hex = hex_neighbor(hex, i + 2)
	return results

static func hex_spiral(center: Vector3, radius: int) -> Array: #Vector3
	var results := []
	for k in range(radius+1):
		results.append_array(hex_ring(center, k))
	return results

# conversion
static func hex2flatOffset(offsetType: int, hex: Vector3) -> Vector2:
	assert(offsetType == OffsetType.EVEN || offsetType == OffsetType.ODD)
	var col := hex.x
	var row := hex.y + int((hex.x + offsetType * (int(hex.x) & 1)) / 2)
	return Vector2(col, row)

static func flatOffset2hex(offsetType: int, offset: Vector2) -> Vector3:
	assert(offsetType == OffsetType.EVEN || offsetType == OffsetType.ODD)
	var q := offset.x
	var r := offset.y - int((offset.x + offsetType * (int(offset.x) & 1)) / 2)
	var s := - q - r
	return Vector3(q, r, s)

static func hex2pointyOffset(offsetType: int, hex: Vector3) -> Vector2:
	assert(offsetType == OffsetType.EVEN || offsetType == OffsetType.ODD)
	var col := hex.x + int((hex.y + offsetType * (int(hex.y) & 1)) / 2)
	var row := hex.y
	return Vector2(col, row)

static func pointyOffset2hex(offsetType: int, offset: Vector2) -> Vector3:
	assert(offsetType == OffsetType.EVEN || offsetType == OffsetType.ODD)
	var q := offset.x - int((offset.y + offsetType * (int(offset.y) & 1)) / 2)
	var r := offset.y
	var s := - q - r
	return Vector3(q, r, s)
