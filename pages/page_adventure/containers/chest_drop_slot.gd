extends Button

@export var chest: BoxContainer
var drag_and_drop_disabled: bool = false

func _can_drop_data(_at_position: Vector2, in_data: Variant) -> bool:
	if drag_and_drop_disabled: return false
	if not in_data is ItemCurrentData: return false
	var item_current_data: ItemCurrentData = in_data as ItemCurrentData
	for child_index: int in range(0, chest.get_child_count() - 1, 1):
		var child: SkillSlot = chest.get_child(child_index) as SkillSlot
		if child._can_drop_data(Vector2.ZERO, item_current_data):
			return true
	return false

func _drop_data(_at_position: Vector2, in_data: Variant) -> void:
	var item_current_data: ItemCurrentData = in_data as ItemCurrentData
	if item_current_data == null:
		printerr("Tryied to drop: ", in_data)
		return
	for child_index: int in range(0, chest.get_child_count(), 1):
		var child: SkillSlot = chest.get_child(child_index) as SkillSlot
		if child._can_drop_data(Vector2.ZERO, item_current_data):
			child._drop_data(Vector2.ZERO, item_current_data)
			return
