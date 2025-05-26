extends Control
class_name SkillSlot

const skill_object_ps: PackedScene = preload("uid://d1hlfk3rlejcs")

signal on_dragged_success()

var data: SkillData = null
var object_index: int
var tmp_data: SkillData = null
var tmp_object_index: int = 0
var dragg_cost: int = 0

@export var drag_disabled: bool = false
@export var drop_disabled: bool = false

@onready var index: int = get_index()

func _get_drag_data(_at_position: Vector2) -> Variant:
	if drag_disabled: return null
	if is_empty(): return null
	if dragg_cost > AdventureResources.coins: return null

	tmp_data = data.duplicate(true)
	tmp_object_index = object_index

	var preview_texture: TextureRect = TextureRect.new()
	preview_texture.texture = tmp_data.icon
	preview_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview_texture.size = Vector2(size.x, 50 * tmp_data.size + (tmp_data.size - 1) * 4)
	var preview_node: Control = Control.new()
	preview_node.add_child(preview_texture)
	set_drag_preview(preview_node)

	get_parent().get_child(object_index).get_child(0).queue_free()
	for child_index: int in range(object_index, object_index + tmp_data.size, 1):
		var sibling: SkillSlot = get_parent().get_child(child_index) as SkillSlot
		sibling.data = null
		sibling.object_index = sibling.index

	return tmp_data

func _notification(what: int) -> void:
	if tmp_data == null:
		return
	if what == Node.NOTIFICATION_DRAG_END and get_viewport().gui_is_drag_successful():
		on_dragged_success.emit(tmp_data)
		tmp_data = null
		tmp_object_index = 0
		AdventureResources.coins -= dragg_cost
		dragg_cost = 0
	elif what == Node.NOTIFICATION_DRAG_END and not get_viewport().gui_is_drag_successful():
		get_parent().get_child(tmp_object_index)._drop_data(Vector2.ZERO, tmp_data)

func _can_drop_data(_at_position: Vector2, in_data: Variant) -> bool:
	if drop_disabled: return false
	var skill_data: SkillData = in_data as SkillData
	if skill_data == null: return false
	return skill_data.size <= get_space()

func _drop_data(_at_position: Vector2, in_data: Variant) -> void:
	var skill_data: SkillData = in_data as SkillData
	if skill_data == null:
		printerr("Tryied to drop: ", in_data)
		return
	for child_index: int in range(index, index + skill_data.size, 1):
		var sibling: SkillSlot = get_parent().get_child(child_index) as SkillSlot
		sibling.data = skill_data
		sibling.object_index = index
	var skill_object: SkillObject = skill_object_ps.instantiate()
	add_child(skill_object)
	skill_object.data = skill_data
	

func get_space() -> int:
	for child_index: int in range(index, get_parent().get_child_count() - 1, 1):
		var sibling: SkillSlot = get_parent().get_child(child_index) as SkillSlot
		if sibling and not sibling.is_empty():
			return child_index - index
	return get_parent().get_child_count() - index

func is_empty() -> bool:
	return data == null

func _ready() -> void:
	var skill_object: SkillObject

	if get_child_count() > 0 and get_child(0) is SkillObject:
		skill_object = get_child(0)
	
	if skill_object != null:
		_drop_data(Vector2.ZERO, skill_object.data)
		skill_object.queue_free()

func clear() -> void:
	data = null
	object_index = index
	tmp_data = null
	tmp_object_index = 0
	dragg_cost = 0
	drag_disabled = false
	drop_disabled = false
	for i: int in get_child_count():
		if get_child(i) is SkillObject:
			get_child(i).queue_free()