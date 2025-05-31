extends Control
class_name Tooltip

@export var rich_text: RichTextLabel

func _ready() -> void:
	get_parent().set_deferred("size", Vector2.ZERO)

func set_text(in_str: String) -> void:
	rich_text.text = in_str


const tooltip_ps: PackedScene = preload("uid://id3gv3ymu6qd")

static func make_custom_tooltip(for_text: String) -> Object:
	if for_text.is_empty():
		return null
	var tooltip: Tooltip = tooltip_ps.instantiate()
	tooltip.set_text(for_text)
	return tooltip
