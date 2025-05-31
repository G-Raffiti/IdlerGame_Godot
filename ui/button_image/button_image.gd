@tool
extends Control
class_name ButtonImage

signal pressed()

@onready var _button: Button = %"Button"
@onready var _image_node: TextureRect = %"TextureRect"
@onready var _text_node: RichTextLabel = %"RichTextLabel"
@onready var hover_image: NinePatchRect = %"NinePatchRect"

@export var image: Texture2D:
	get: return image
	set(value):
		image = value
		if not is_inside_tree(): return
		_image_node.texture = value

@export var text: String:
	get: return text
	set(value):
		text = value
		if not is_inside_tree(): return
		_text_node.text = value

@export var text_tooltip: String:
	get: return text_tooltip
	set(value): 
		text_tooltip = value
		if not is_inside_tree(): return
		_button.tooltip_text = value

func _ready() -> void:
	_button.pressed.connect(func() -> void: pressed.emit())
	_button.mouse_entered.connect(func() -> void: hover_image.visible = true)
	_button.mouse_exited.connect(func() -> void: hover_image.visible = _button.button_pressed)
	image = image
	text = text
	text_tooltip = text_tooltip
	hover_image.visible = _button.button_pressed

func _make_custom_tooltip(for_text: String) -> Object:
	return Tooltip.make_custom_tooltip(for_text)
