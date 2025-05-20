@tool
extends Node
@export_tool_button("Save") var save_callable: Callable = call_save
@export_tool_button("Load") var load_callable: Callable = call_load
@export var auto_save_res: AutoSaveRes
@export var saved_res: Dictionary[String, Variant]

func call_save() -> void:
	saved_res = auto_save_res.save()

func call_load() -> void:
	auto_save_res.load_data(saved_res)
