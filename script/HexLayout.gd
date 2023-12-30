extends Reference
class_name HexLayout

const layout_pointy := [sqrt(3.0), sqrt(3.0) / 2.0, 0.0, 3.0 / 2.0,
					   sqrt(3.0) / 3.0, -1.0 / 3.0, 0.0, 2.0 / 3.0,
					   0.5]
const layout_flat := [3.0 / 2.0, 0.0, sqrt(3.0) / 2.0, sqrt(3.0),
					 2.0 / 3.0, 0.0, -1.0 / 3.0, sqrt(3.0) / 3.0,
					 0.0]

# Public properties
var is_flat := true
var size := Vector2(10, 10)
var origin := Vector2(0, 0)
var orientation: Array setget ,get_orientation

# Setters/Getters
func get_orientation() -> Array: 
	if is_flat:
		return layout_flat
	else:
		return layout_pointy

func _init(_is_flat: bool, _size: Vector2, _origin: Vector2 = Vector2.ZERO):
	is_flat = _is_flat
	size = _size
	origin = _origin

func hex_to_pixel(h: Vector3) -> Vector2:
	var M := self.orientation
	var x = (M[0] * h.x + M[1] * h.y) * size.x
	var y = (M[2] * h.x + M[3] * h.y) * size.y
	return Vector2(x + origin.x, y + origin.y)

func pixel_to_fractHex(p: Vector2) -> Vector3:
	var M := self.orientation
	var pt := Vector2((p.x - origin.x) / size.x, (p.y - origin.y) / size.y)
	var q = M[4] * pt.x + M[5] * pt.y
	var r = M[6] * pt.x + M[7] * pt.y
	return Vector3(q, r, - q - r)

func pixel_to_hex(p: Vector2) -> Vector3:
	return Hex.hex_round(pixel_to_fractHex(p))

func hex_corner_offset(corner: int) -> Vector2:
	var angle = 2.0 * PI * (orientation[8] + corner) / 6
	return Vector2(size.x * cos(angle), size.y * sin(angle))

func polygon_corners(h: Vector3) -> Array: #Vector2
	var corners := []
	var center := hex_to_pixel(h)
	for i in range(6):
		var offset := hex_corner_offset(i)
		corners.push_back(center + offset)
	return corners
