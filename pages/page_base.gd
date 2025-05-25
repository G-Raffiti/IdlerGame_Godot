extends Node
class_name PageBase

var manager: Manager

func _ready() -> void:
	SignalBus.on_manager_ready.connect(register_to_manager)
	RS.on_current_boss_level_changed.connect(_on_current_boss_level_changed)

func register_to_manager(in_manager: Manager) -> void:
	manager = in_manager
	pass

func open_page() -> void:
	pass

func close_page() -> void:
	pass

func _on_current_boss_level_changed(_in_current_boss_level: int) -> void:
	pass
