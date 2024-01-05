extends Item
class_name ItemBubble

static var Default = load("res://resource/item/ItemBubble.tres")

func equals(other: Item) -> bool:
	return other is ItemBubble
