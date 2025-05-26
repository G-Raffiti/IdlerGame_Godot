@tool
extends Control
class_name Board

@export var slots: VBoxContainer

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
	if not in_data is SkillData: return false
	var skill_data: SkillData = in_data as SkillData
	for child_index: int in range(0, slots.get_child_count() - 1, 1):
		var child: SkillSlot = slots.get_child(child_index) as SkillSlot
		if child._can_drop_data(Vector2.ZERO, skill_data):
			return true
	return false

func _drop_data(_at_position: Vector2, in_data: Variant) -> void:
	var skill_data: SkillData = in_data as SkillData
	if skill_data == null:
		printerr("Tryied to drop: ", in_data)
		return
	for child_index: int in range(0, slots.get_child_count(), 1):
		var child: SkillSlot = slots.get_child(child_index) as SkillSlot
		if child._can_drop_data(Vector2.ZERO, skill_data):
			child._drop_data(Vector2.ZERO, skill_data)
			return

func try_drop_skill(in_data: SkillData, in_can_be_dragged: bool = true, in_can_be_dropped: bool = true, in_dragg_cost: int = 0, in_callback_on_dragged_success: Callable = Callable()) -> bool:
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
