extends Control
class_name SkillSlot

const skill_object_ps: PackedScene = preload("uid://d1hlfk3rlejcs")

signal on_dragged_success()

var current_item: ItemCurrentData = null
var object_index: int
var tmp_item: ItemCurrentData = null
var tmp_object_index: int = 0
var dragg_cost: int = 0

@export var drag_disabled: bool = false
@export var drop_disabled: bool = false

@onready var index: int = get_index()

func _get_drag_data(_at_position: Vector2) -> Variant:
	if drag_disabled: return null
	if is_empty(): return null
	if dragg_cost > AdventureResources.coins: return null

	tmp_item = current_item.duplicate(true)
	tmp_object_index = object_index

	var preview_texture: TextureRect = TextureRect.new()
	preview_texture.texture = tmp_item.data.icon
	preview_texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	preview_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	preview_texture.size = Vector2(size.y, 69 * tmp_item.data.size + (tmp_item.data.size - 1) * 4)
	var preview_node: Control = Control.new()
	preview_node.add_child(preview_texture)
	set_drag_preview(preview_node)

	get_parent().get_child(object_index).get_child(0).queue_free()
	for child_index: int in range(object_index, object_index + tmp_item.data.size, 1):
		var sibling: SkillSlot = get_parent().get_child(child_index) as SkillSlot
		sibling.current_item = null
		sibling.object_index = sibling.index

	return tmp_item

func _notification(what: int) -> void:
	if tmp_item == null:
		return
	if what == Node.NOTIFICATION_DRAG_END and get_viewport().gui_is_drag_successful():
		on_dragged_success.emit(tmp_item)
		tmp_item = null
		tmp_object_index = 0
		AdventureResources.coins -= dragg_cost
		dragg_cost = 0
	elif what == Node.NOTIFICATION_DRAG_END and not get_viewport().gui_is_drag_successful():
		get_parent().get_child(tmp_object_index)._drop_data(Vector2.ZERO, tmp_item)

func _can_drop_data(_at_position: Vector2, in_data: Variant) -> bool:
	if drop_disabled: return false
	var item_current_data: ItemCurrentData = in_data as ItemCurrentData
	if item_current_data == null: return false
	return item_current_data.data.size <= get_space()

func _drop_data(_at_position: Vector2, in_data: Variant) -> void:
	var item_current_data: ItemCurrentData = in_data as ItemCurrentData
	if item_current_data == null:
		printerr("Tryied to drop: ", in_data)
		return
	for child_index: int in range(index, index + item_current_data.data.size, 1):
		var sibling: SkillSlot = get_parent().get_child(child_index) as SkillSlot
		sibling.current_item = item_current_data
		sibling.object_index = index
	var skill_object: SkillObject = skill_object_ps.instantiate()
	add_child(skill_object)
	skill_object.current = item_current_data
	

func get_space() -> int:
	for child_index: int in range(index, get_parent().get_child_count() - 1, 1):
		var sibling: SkillSlot = get_parent().get_child(child_index) as SkillSlot
		if sibling and not sibling.is_empty():
			return child_index - index
	return get_parent().get_child_count() - index

func is_empty() -> bool:
	return current_item == null

func _ready() -> void:
	var skill_object: SkillObject

	if get_child_count() > 0 and get_child(0) is SkillObject:
		skill_object = get_child(0)
	
	if skill_object != null:
		var current_data: ItemCurrentData = skill_object.current
		skill_object.queue_free()
		await get_tree().process_frame
		await get_tree().process_frame
		_drop_data(Vector2.ZERO, current_data)

func clear_current_item() -> void:
	if is_empty(): return
	for i : int in range(object_index, object_index + current_item.data.size, 1):
		get_parent().get_child(i).clear()

func clear() -> void:
	current_item = null
	object_index = index
	tmp_item = null
	tmp_object_index = 0
	dragg_cost = 0
	drag_disabled = false
	drop_disabled = false
	SignalBus.clear_signal(on_dragged_success)
	for i: int in get_child_count():
		if get_child(i) is SkillObject:
			get_child(i).queue_free()

func _get_tooltip(_at_position: Vector2) -> String:
	if is_empty(): return ""
	return "[b][color=wheat]" + current_item.data.name + "[/color][/b]\n" + current_item.data.description

func _make_custom_tooltip(for_text: String) -> Object:
	return Tooltip.make_custom_tooltip(for_text)
