extends Item
class_name ItemBubble

static var Default = ItemBubble.new()

func equals(other: Item) -> bool:
	return other is ItemBubble
