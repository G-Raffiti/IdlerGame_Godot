extends Node
class_name SaveLoadSystem

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	call_load()
	var timer: Timer = Timer.new()
	timer.wait_time = 60
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(call_save)
	add_child(timer)

func call_save() -> void:
	var saved_nodes: Dictionary[NodePath, Variant] = {}
	var to_save_nodes: Array[Node] = Utils.get_all_children_whith_variable(get_tree().root, "saveable")
	for node: Node in to_save_nodes:
		print("Saved: ", node.name)
		var path: NodePath = node.get_path()
		saved_nodes[path] = {}
		var list: Array[Dictionary] = node.get_script().get_script_property_list()
		var save_exception: Array[String] = ["saveable", "save_exception", "script"]
		if "save_exception" in node:
			save_exception.append_array(node.save_exception)
		for dict: Dictionary in list:
			# Skip save_exception var
			if save_exception.has(dict["name"]): continue
			# Skip the @export_group()
			if dict["type"] == 0: continue
			# Skip Node Refs
			if dict["type"] == 24 && (node.get(dict["name"]) == null or node.get(dict["name"]) is Node): continue

			if dict["type"] != 24:
				saved_nodes[path][dict["name"]] = node.get(dict["name"])
			else:
				saved_nodes[path][dict["name"]] = AutoSaveRes.save_obj(node.get(dict["name"]))
	var save: SaveRes = SaveRes.new()
	save.saved_nodes = saved_nodes
	save.time = Time.get_datetime_dict_from_system()
	ResourceSaver.save(save, "user://savegame.tres")


func call_load() -> void:
	if not FileAccess.file_exists("user://savegame.tres"):
		return
	var save: Resource = ResourceLoader.load("user://savegame.tres")
	if save == null:
		printerr("Failed to load user://savegame.tres")
		return

	for node_path: NodePath in save.saved_nodes:
		var node: Node = get_node(node_path)
		if node == null:
			printerr("Load Failed for ", node_path.get_name(node_path.get_name_count() - 1))
			continue
		for var_name: String in save.saved_nodes[node_path]:
			if not var_name in node:
				printerr("Load Failed for ", node.get_name(), ": The node dosen't has a property named: ", var_name)
				continue
			node.set_deferred(var_name, save.saved_nodes[node_path][var_name])
		print("Loaded: ", node.name)
	await get_tree().create_timer(1.0).timeout
	RS.gain_offline_progress(save.time)
			
