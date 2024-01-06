extends InfoPanel
class_name InfoItem

@export var item: ItemObject

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	categoryLabel.text = "Item"
	if item and item.item:
		sprite.texture = item.item.texture
		titleLabel.text = item.item.name
