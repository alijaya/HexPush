extends RefCounted
class_name Util

static func get_flag(b: int, i: int) -> bool:
	return b & (1 << i) != 0

static func set_flag(b: int, i: int) -> int:
	return b | (1 << i)

static func unset_flag(b: int, i: int) -> int:
	return b & ~(1 << i)
