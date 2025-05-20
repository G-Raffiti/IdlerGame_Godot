extends Resource
class_name ResourceAllocator_Data

@export_group("Display")
@export var display_name: String = ""
@export var display_level: bool = true
@export var unlock_level: int = 0
@export_multiline var tooltip_message: String = ""

@export_group("Values")
@export var maximum_allocated: Vector2 = Vector2(1.0, 3)
@export var fill_duration_at_maximum: Vector2 = Vector2(1.0, 0)
@export var increase_factor_on_bar_filled: Vector2 = Vector2(1.0, 0)

@export_group("Click")
@export var _click_enabled: bool

@export_group("Rebirth")
@export var should_decrease_maximum_after_rebirth: bool = false
@export var decrease_factor_on_rebirth_maximum: Vector2 = Vector2(9.0, -1)
@export var decrease_maximum_on_rebirth_per_bar_filled: Vector2 = Vector2(1.0, 0)
