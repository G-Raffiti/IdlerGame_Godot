@tool
extends HBoxContainer
class_name SkillBar

signal on_bar_filled()

@export var fill_color: Color:
	set(value):
		fill_color = value
		if not is_inside_tree(): return
		progress_bar.get("theme_override_styles/fill").set("bg_color", value)

@export var back_color: Color:
	set(value):
		back_color = value
		if not is_inside_tree(): return
		progress_bar.get("theme_override_styles/background").set("bg_color", value)

@export var font_color: Color

var timer: Timer


@onready var progress_bar: ProgressBar = %ProgressBar
@onready var label: RichTextLabel = %RichTextLabel


var full_duration: Vector2
var current_duration: Vector2:
	set(value):
		if Number.is_greater_or_equal(value, full_duration):
			current_duration = Vector2(0.0, 0)
			on_bar_filled.emit()
		else:
			current_duration = value
		if not is_inside_tree(): return
		progress_bar.value = Number.to_float(Number.div(current_duration, full_duration))

func set_text(in_text: String) -> void:
	label.text = "[color=" + font_color.to_html() + "]" + in_text + "[/color]"

func set_duration(in_duration: Vector2) -> void:
	full_duration = Number.div(in_duration, Settings.income_frequency_number)

func initialize() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = false
	timer.wait_time = Settings.income_frequency
	timer.timeout.connect(_on_tick)
	timer.autostart = false

func _on_tick() -> void:
	current_duration = Number.add(current_duration, Vector2(1.0, 0))

func start() -> void:
	timer.start()

func stop() -> void:
	timer.stop()
	current_duration = Vector2.ZERO

func _ready() -> void:
	fill_color = fill_color
	back_color = back_color
	current_duration = Vector2.ZERO

func _make_custom_tooltip(for_text: String) -> Object:
	return Tooltip.make_custom_tooltip(for_text)
