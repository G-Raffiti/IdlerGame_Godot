@tool
extends PanelContainer
class_name AdventureSkillObjectNumber

signal on_timer_ends()

var num_value: float = 0.0
var has_timer: bool = false

@export var color: Color:
    get: return color
    set(value):
        color = value
        if not is_inside_tree(): return
        if not nine_patch.texture is GradientTexture2D: return
        var colors: PackedColorArray = nine_patch.texture.gradient.get("colors").duplicate()
        colors[1] = value
        nine_patch.texture.gradient.set("colors", colors)

@export var is_allways_visible: bool:
    set(value):
        is_allways_visible = value
        if not is_inside_tree(): return
        if value:
            visible = true

@onready var nine_patch: NinePatchRect = %"NinePatchRect"
@onready var label: RichTextLabel = %"RichTextLabel"

func _ready() -> void:
    color = color
    visible = is_allways_visible

func set_value(in_number: float) -> void:
    num_value = in_number
    label.text = str(num_value)
    visible = is_allways_visible or num_value > 0


func set_timer(in_time: float) -> void:
    has_timer = true
    set_value(in_time)

func _process(in_delta: float) -> void:
    if not has_timer: return
    set_value(num_value - in_delta)
    if num_value <= 0:
        has_timer = false
        on_timer_ends.emit()