@tool
extends PanelContainer

@onready var text_node: RichTextLabel = $MarginContainer/RichTextLabel

@export var text: String:
		set(value):
				text = value
				if not is_inside_tree():
						return
				text_node.text = value

func _ready() -> void:
	text = text
