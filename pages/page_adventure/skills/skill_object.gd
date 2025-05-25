@tool
extends Button
class_name SkillObject

signal on_activate(in_index: int, in_data: SkillData)

@onready var texture: TextureRect = $"TextureRect"
@onready var time_bar: ProgressBar = %"time_bar"
var timer: Timer
var started: bool = false

@export var data: SkillData:
	get: return data
	set(value):
		if data != null and data.on_value_changed.is_connected(_on_data_value_changed):
			data.on_value_changed.disconnect(_on_data_value_changed)
		data = value
		if value != null and not data.on_value_changed.is_connected(_on_data_value_changed):
			value.on_value_changed.connect(_on_data_value_changed)
		call_deferred("_on_data_value_changed")

func _on_data_value_changed() -> void:
	if not is_inside_tree(): return
	if data == null: return

	# Size
	custom_minimum_size.y = 50 * data.size + (data.size - 1) * 4
	size.y = custom_minimum_size.y
	position = Vector2.ZERO

	# Icon
	texture.texture = data.icon

func _activate() -> void:
	on_activate.emit(get_parent().index, data)

func start() -> void:
	if data.time <= 0.0:
		return
	time_bar.max_value = data.time
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = data.time
	timer.one_shot = false
	timer.timeout.connect(_activate)
	started = true

func _ready() -> void:
	time_bar.value = 0.0

func _process(_delta: float) -> void:
	if not started: return
	time_bar.value = data.time - timer.time_left
