@tool
extends Button
class_name ProgressBarButton

@export_multiline var text_value: String:
	set(value):
		text_value = value
		if not is_inside_tree(): 
			return
		%TextValue.text = value
		resize_minimum()

@export_multiline var tooltip_base_text: String

@export var fit_content: bool = false:
	set(value):
		fit_content = value
		if not is_inside_tree(): 
			return
		resize_minimum()

@export var enabled: bool = true:
	set(value):
		enabled = value
		disabled = !value
		if not is_inside_tree():
			return
		$Locked.visible = !value

@export_group("Colors")
@export var font_color: Color = Color.WHITE:
	set(value):
		font_color = value
		if not is_inside_tree():
			return
		%TextValue.set("theme_override_colors/default_color", value)

@export var back_color: Color:
	set(value):
		back_color = value
		if not is_inside_tree():
			return
		var style: StyleBoxFlat = $MarginContainer/ProgressBar.get("theme_override_styles/background").duplicate(true)
		style.bg_color = value
		$MarginContainer/ProgressBar.set("theme_override_styles/background", style)

@export var fill_color: Color:
	set(value):
		fill_color = value
		if not is_inside_tree():
			return
		var style: StyleBoxFlat = $MarginContainer/ProgressBar.get("theme_override_styles/fill").duplicate(true)
		style.bg_color = value
		$MarginContainer/ProgressBar.set("theme_override_styles/fill", style)

@onready var progress: ProgressBar = $MarginContainer/ProgressBar

func resize_minimum() -> void:
	if not is_inside_tree():
		return
	if not fit_content:
		custom_minimum_size = Vector2.ZERO
		return
	await get_tree().process_frame
	if not is_inside_tree():
		return
	$MarginContainer.size.y = 0
	$MarginContainer.size.x = size.x
	$MarginContainer.position = Vector2.ZERO
	await get_tree().process_frame
	if not is_inside_tree():
		return
	var min_size: Vector2 = $MarginContainer.size
	if min_size.x > size.x:
		custom_minimum_size.x = min_size.x
	if min_size.y > size.y:
		custom_minimum_size.y = min_size.y
	if min_size.y < custom_minimum_size.y:
		custom_minimum_size.y = min_size.y
	
func _ready() -> void:
	text_value = text_value
	fit_content = fit_content
	enabled = enabled
	font_color = font_color
	fill_color = fill_color
	back_color = back_color
	progress.value = 0.0
	progress.max_value = 1.0

func update_progress(in_percent: float) -> void:
	if in_percent > 0:
		enabled = true
	progress.value = in_percent

func _get_tooltip(at_position: Vector2) -> String:
	if enabled == false: return ""
	return tooltip_base_text

func _make_custom_tooltip(for_text: String) -> Object:
	return Tooltip.make_custom_tooltip(for_text)
