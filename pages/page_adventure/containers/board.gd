@tool
extends Control
class_name Board

@export var slots: BoxContainer

@export var drag_disabled: bool = false:
	set(value):
		drag_disabled = value
		if not is_inside_tree(): return
		for child_index: int in range(0, slots.get_child_count() - 1, 1):
			var child: SkillSlot = slots.get_child(child_index) as SkillSlot
			if child == null: continue
			child.drag_disabled = value
@export var drop_disabled: bool = false:
	set(value):
		drop_disabled = value
		if not is_inside_tree(): return
		for child_index: int in range(0, slots.get_child_count() - 1, 1):
			var child: SkillSlot = slots.get_child(child_index) as SkillSlot
			if child == null: continue
			child.drop_disabled = value

func _can_drop_data(_at_position: Vector2, in_data: Variant) -> bool:
	if drop_disabled: return false
	if not in_data is ItemCurrentData: return false
	var item_data: ItemCurrentData = in_data as ItemCurrentData
	for child_index: int in range(0, slots.get_child_count() - 1, 1):
		var child: SkillSlot = slots.get_child(child_index) as SkillSlot
		if child._can_drop_data(Vector2.ZERO, item_data):
			return true
	return false

func _drop_data(_at_position: Vector2, in_data: Variant) -> void:
	var item_data: ItemCurrentData = in_data as ItemCurrentData
	if item_data == null:
		printerr("Tryied to drop: ", in_data)
		return
	for child_index: int in range(0, slots.get_child_count(), 1):
		var child: SkillSlot = slots.get_child(child_index) as SkillSlot
		if child._can_drop_data(Vector2.ZERO, item_data):
			child._drop_data(Vector2.ZERO, item_data)
			return

func try_drop_skill(in_data: ItemCurrentData, in_can_be_dragged: bool = true, in_can_be_dropped: bool = true, in_dragg_cost: int = 0, in_callback_on_dragged_success: Callable = Callable()) -> bool:
	for child_index: int in range(0, slots.get_child_count(), 1):
		var child: SkillSlot = slots.get_child(child_index) as SkillSlot
		if child._can_drop_data(Vector2.ZERO, in_data):
			child._drop_data(Vector2.ZERO, in_data)
			child.drag_disabled = !in_can_be_dragged
			child.drop_disabled = !in_can_be_dropped
			child.dragg_cost = in_dragg_cost
			if not in_callback_on_dragged_success.is_null():
				child.on_dragged_success.connect(in_callback_on_dragged_success, CONNECT_ONE_SHOT)
			return true
	return false

func center_items() -> void:
	var total_empty_space: int = slots.get_child_count()
	var items: Array[Dictionary] = []
	for child_index: int in range(0, slots.get_child_count(), 1):
		var child: SkillSlot = slots.get_child(child_index) as SkillSlot
		if child.is_empty(): continue
		total_empty_space -= child.current_item.data.size
		var call_back: Callable = Callable()
		if not child.on_dragged_success.get_connections().is_empty():
			call_back = child.on_dragged_success.get_connections()[0]["callable"]
		items.append({"item": child.current_item, "callable": call_back, "cost": child.dragg_cost})
		child.clear_current_item()
	if items.is_empty(): return
	await get_tree().process_frame
	for child_index: int in range(total_empty_space / 2, slots.get_child_count(), 1):
		var child: SkillSlot = slots.get_child(child_index) as SkillSlot
		if not child.is_empty(): continue
		child._drop_data(Vector2.ZERO, items[0]["item"])
		if not (items[0]["callable"] as Callable).is_null():
			child.on_dragged_success.connect(items[0]["callable"], CONNECT_ONE_SHOT)
		child.dragg_cost = items[0]["cost"]
		items.remove_at(0)
		if items.is_empty():
			return

func clear_board() -> void:
	for child_index: int in range(0, slots.get_child_count(), 1):
		var child: SkillSlot = slots.get_child(child_index) as SkillSlot
		child.clear()
