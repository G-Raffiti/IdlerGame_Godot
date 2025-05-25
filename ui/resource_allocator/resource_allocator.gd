@tool
extends HBoxContainer
class_name ResourceAllocator

signal on_change_amount_pressed(in_bar: ResourceAllocator, in_allocation: E.Allocation)
signal on_bar_filled(in_num_bar: Vector2)

const saveable: bool = true

@export_group("Display")
@export var display_name: String = "":
	get(): return display_name
	set(value):
		display_name = value
		if not is_inside_tree():
			return
		progress_bar.text_value = value

@export var display_level: bool:
	set(value):
		display_level = value
		if not is_inside_tree():
			return
		progress_bar.size_flags_stretch_ratio = 1.0 if value else 2.0
		$LevelText.visible = value

@export var is_unlocked: bool:
	set(value):
		is_unlocked = value
		if not is_inside_tree(): return
		$LockedText.visible = !is_unlocked
		$LevelText.visible = is_unlocked
		$AllocatedText.visible = is_unlocked
		$HBoxContainer.visible = is_unlocked

@export var tooltip_message: String

var dynamic_tooltip_value: String:
	set(value):
		dynamic_tooltip_value = value
		if not is_inside_tree(): 
			return
		var percent: float = Number.to_float(Number.div(bar_current_value, bar_total_value))
		progress_bar.tooltip_base_text = _get_tooltip_message(percent)

@export var fill_color: Color:
	set(value):
		fill_color = value
		if not is_inside_tree():
			return
		if progress_bar == null:
			return
		progress_bar.fill_color = value

@export var back_color: Color:
	set(value):
		back_color = value
		if not is_inside_tree():
			return
		if progress_bar == null:
			return
		progress_bar.back_color = value

@export var font_color: Color:
	set(value):
		font_color = value
		if not is_inside_tree():
			return
		if progress_bar == null:
			return
		progress_bar.font_color = value

@export_group("Values")
@export var maximum_allocated: Vector2 = Vector2(1.0, 3):
	set(value):
		maximum_allocated = value
		if not is_inside_tree():
			return
		$AllocatedText.text = Number.to_str(current_allocated) + " / " + Number.to_str(value)
		await get_tree().process_frame
		_update_total_value()

@export var fill_duration_at_maximum: Vector2 = Vector2(1.0, 0):
	set(value):
		fill_duration_at_maximum = value
		if not is_inside_tree():
			return
		await get_tree().process_frame
		_update_total_value()

@export var increase_factor_on_bar_filled: Vector2 = Vector2(1.0, 0)

var level: Vector2 = Vector2.ZERO:
	get: return level
	set(value):
		level = value
		if not is_inside_tree():
			return
		$LevelText.text = Number.to_str(level)

var current_allocated: Vector2 = Vector2(0.0, 0):
	set(value):
		current_allocated = value
		$AllocatedText.text = Number.to_str(value) + " / " + Number.to_str(maximum_allocated)
		if Number.is_zero(value):
			timer.stop()
		elif timer.is_stopped():
			timer.start()

var bar_current_value: Vector2 = Vector2(0.0, 0)

var bar_total_value: Vector2 = Vector2(1.0, 0)


@export_group("Click")
@export var _click_enabled: bool


@export_group("Rebirth")
@export var should_decrease_maximum_after_rebirth: bool = false
@export var decrease_factor_on_rebirth_maximum: Vector2 = Vector2(9.0, -1)
@export var decrease_maximum_on_rebirth_per_bar_filled: Vector2 = Vector2(1.0, 0)
var after_rebirth_maximum: Vector2
var min_after_rebirth_maximum: Vector2

@export_group("Dependencies")
var timer: Timer = null

@onready var progress_bar: ProgressBarButton= %"ProgressBarButton"

func init_data(in_data: ResourceAllocator_Data) -> void:
	display_name = in_data.display_name
	display_level = in_data.display_level
	tooltip_message = in_data.tooltip_message
	maximum_allocated = in_data.maximum_allocated
	fill_duration_at_maximum = in_data.fill_duration_at_maximum
	increase_factor_on_bar_filled = in_data.increase_factor_on_bar_filled
	_click_enabled = in_data.click_enabled
	should_decrease_maximum_after_rebirth = in_data.should_decrease_maximum_after_rebirth
	decrease_factor_on_rebirth_maximum = in_data.decrease_factor_on_rebirth_maximum
	decrease_maximum_on_rebirth_per_bar_filled = in_data.decrease_maximum_on_rebirth_per_bar_filled
	level = level
	
	allocate_resource(Vector2.ZERO)
	_update_total_value()
	after_rebirth_maximum = maximum_allocated
	min_after_rebirth_maximum = Number.max_num(Number.mult(maximum_allocated, decrease_factor_on_rebirth_maximum), Vector2(1.0, 0))
	progress_bar.tooltip_base_text = _get_tooltip_message(0.0)

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if not is_inside_tree():
		return
	$"HBoxContainer/Add".pressed.connect(func() -> void: on_change_amount_pressed.emit(self, E.Allocation.ADD))
	$"HBoxContainer/Remove".pressed.connect(func() -> void: on_change_amount_pressed.emit(self, E.Allocation.REMOVE))
	$"HBoxContainer/Max".pressed.connect(func() -> void: on_change_amount_pressed.emit(self, E.Allocation.MAX))
	if _click_enabled:
		progress_bar.pressed.connect(func() -> void: _on_fast_time(Vector2(1.0, 0)))
	timer = Timer.new()
	timer.autostart = false
	timer.one_shot = false
	timer.wait_time = Settings.income_frequency
	timer.timeout.connect(_on_tick)
	add_child(timer)
	fill_color = fill_color
	back_color = back_color
	font_color = font_color
	RS.on_offline_progress_time_calculated.connect(_on_fast_time)

func _on_tick(in_mult: Vector2 = Vector2(1.0, 0)) -> void:
	bar_current_value = Number.add(bar_current_value, Number.mult(current_allocated, in_mult))
	var percent: float = Number.to_float(Number.div(bar_current_value, bar_total_value))
	progress_bar.update_progress(percent)
	progress_bar.tooltip_base_text = _get_tooltip_message(percent)
	if percent < 1.0:
		return
	on_bar_filled.emit(Vector2(1.0, 0))
	bar_current_value = Vector2.ZERO
	maximum_allocated = Number.mult(maximum_allocated, increase_factor_on_bar_filled)
	_update_total_value()
	level = Number.add(level, Vector2(1.0, 0))
	_decrease_rebirth_maximum()


func _update_total_value() -> void:
	if Engine.is_editor_hint():
		return
	bar_total_value = Number.div(Number.mult(maximum_allocated, fill_duration_at_maximum), Settings.income_frequency_number)


func _get_tooltip_message(in_percent: float) -> String:
	var _str: String = ""
	if not dynamic_tooltip_value.is_empty():
		_str = "\n\n" + dynamic_tooltip_value
	if should_decrease_maximum_after_rebirth:
		var color: String = "[color=green]" if is_next_rebirth_opti() else "[color=white]"
		_str += "\n\nMaximum after [b][color=medium_purple]Rebirth[/color][/b]: " + color + Number.to_str(after_rebirth_maximum) + "[/color]"
	if _click_enabled:
		_str += "\n\n[b]Click Here[/b] to fill the Bar as if waiting 1sec"
	_str += "\n"
	if not Number.is_zero(current_allocated):
		var current_total_duration: Vector2 = Number.div(fill_duration_at_maximum, Number.div(current_allocated, maximum_allocated))
		_str += "\n" + Number.to_str_time(Number.mult_float(current_total_duration, in_percent)) + " / " + Number.to_str_time(current_total_duration)
	return tooltip_message + _str + "\n(Minimum Duration to Fill a Bar: " + Number.to_str_time(fill_duration_at_maximum) + ")"


func allocate_resource(in_amount: Vector2) -> Vector2:
	var rest: Vector2 = current_allocated
	current_allocated = Number.clamp(Number.add(current_allocated, in_amount), Vector2.ZERO, maximum_allocated)
	return Number.sub(in_amount, Number.sub(current_allocated, rest))


func is_next_rebirth_opti() -> bool:
	return Number.is_smaller_or_equal(after_rebirth_maximum, min_after_rebirth_maximum)


func _decrease_rebirth_maximum() -> void:
	if not should_decrease_maximum_after_rebirth or is_next_rebirth_opti():
		return
	after_rebirth_maximum = Number.max_num(Vector2(1.0, 0), Number.sub(after_rebirth_maximum, decrease_maximum_on_rebirth_per_bar_filled))


func set_unlocked(in_message: String, in_state: bool) -> void:
	$LockedText.text = in_message
	is_unlocked = in_state

func _on_fast_time(in_delta_time: Vector2) -> void:
	var add_per_sec: Vector2 = Number.div(current_allocated, Settings.income_frequency_number)
	var total_added: Vector2 = Number.mult(add_per_sec, in_delta_time)
	var total_bar_filled: Vector2 = Vector2.ZERO

	var added: Vector2 = Vector2.ZERO
	while Number.is_greater(Number.sub(total_added, added), bar_total_value):
		added = Number.add(added, bar_total_value)
		maximum_allocated = Number.mult(maximum_allocated, increase_factor_on_bar_filled)
		_update_total_value()
		_decrease_rebirth_maximum()
		total_bar_filled = Number.add(total_bar_filled, Vector2(1.0, 0))

	bar_current_value = Number.add(bar_current_value, Number.sub(total_added, added))
	level = Number.add(level, total_bar_filled)
	var percent: float = Number.to_float(Number.div(bar_current_value, bar_total_value))
	progress_bar.update_progress(percent)
	progress_bar.tooltip_base_text = _get_tooltip_message(percent)
	on_bar_filled.emit(total_bar_filled)
