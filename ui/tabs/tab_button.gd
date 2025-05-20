extends Button
class_name TabButton

func _make_custom_tooltip(for_text: String) -> Object:
	return Tooltip.make_custom_tooltip(for_text)
