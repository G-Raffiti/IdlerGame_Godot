extends Resource
class_name TabUnlock_Data

@export var page_name: String
@export_multiline var page_tooltip: String
@export_node_path("TabButton") var tab_button: NodePath
@export_node_path("PageBase") var page_to_open: NodePath
@export var unlock_boss_level: int = 0
