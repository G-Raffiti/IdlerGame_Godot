@tool
extends Button
class_name ButtonRich

@onready var rich_text: RichTextLabel = %"RichTextLabel"

@export_multiline var button_text: String:
    get: return button_text
    set(value):
        button_text = value
        if not is_inside_tree(): return
        rich_text.text = value

func _ready() -> void:
    button_text = button_text

func _make_custom_tooltip(for_text: String) -> Object:
    return Tooltip.make_custom_tooltip(for_text)