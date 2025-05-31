extends Node
class_name SaveLoadSystem

###
# Copy this Lines on any Node tha have to be Saved:
#
# const saveable: bool = true
# const save_excception: Array[String] = []
###

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	call_load()
	var timer: Timer = Timer.new()
	timer.wait_time = 60
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(call_save)
	add_child(timer)


static func save_node(in_node: Node) -> Dictionary:
	var saved_node: Dictionary[String, Variant] = {}
	var list: Array[Dictionary] = in_node.get_script().get_script_property_list()
	var save_exception: Array[String] = ["saveable", "save_exception", "script"]
	if "save_exception" in in_node:
		save_exception.append_array(in_node.save_exception)
	for dict: Dictionary in list:
		# Skip save_exception var
		if save_exception.has(dict["name"]): continue
		# Skip the @export_group()
		if dict["type"] == 0: continue
		# Skip Node Refs
		if dict["type"] == 24 && (in_node.get(dict["name"]) == null or in_node.get(dict["name"]) is Node): continue

		if dict["type"] != 24:
			saved_node[dict["name"]] = in_node.get(dict["name"])
		else:
			saved_node[dict["name"]] = save_resource(in_node.get(dict["name"]))

	return saved_node



static func load_node(in_node: Node, in_data: Dictionary) -> void:
	for var_name: String in in_data:
		if not var_name in in_node:
			printerr("Load Failed for ", in_node.get_name(), ": The node dosen't has a property named: ", var_name)
			continue
		in_node.set_deferred(var_name, in_data[var_name])



static func save_resource(in_object: Resource) -> Dictionary[String, Variant]:
	var save_data: Dictionary[String, Variant] = {}
	for i: int in range(0, in_object.get_property_list().size(), 1):
		var var_data: Dictionary = in_object.get_property_list()[i]
		#Skip the resource base variable
		if var_data["name"].is_empty():
			continue
		#Skip the @export_group
		if var_data["type"] == 0:
			continue

		# Skip Native Var Like Script
		if ["metadata/_custom_type_script",
			"resource_local_to_scene",
			"resource_name",
			"resource_path",
			"resource_scene_unique_id",
			"script",
		].has(var_data["name"]):
			continue
		
		#Save the resources by calling the same method recurcively
		if var_data["type"] == 24:
			var sub_object: Object = in_object.get(var_data["name"])
			if sub_object == null:
				save_data[var_data["name"]] = null
			elif sub_object is Resource:
				save_data[var_data["name"]] = save_resource(sub_object)
		else:
			# Save
			save_data[var_data["name"]] = in_object.get(var_data["name"])
	return save_data



static func load_resource(in_object: Resource, in_data: Dictionary[String, Variant]) -> void:
	for i: int in range(0, in_object.get_property_list().size(), 1):
		var var_data: Dictionary = in_object.get_property_list()[i]
		if var_data["name"].is_empty():
			continue
		if not in_data.has(var_data["name"]):
			continue
		if var_data["type"] == 24:
			if in_data[var_data["name"]].has("resource_path") and not in_data[var_data["name"]]["resource_path"].is_empty():
				if in_object.get(var_data["name"]) != null and in_object.get(var_data["name"]).resource_path == in_data[var_data["name"]]["resource_path"]:
					continue
				print(var_data["name"], " -> load(", in_data[var_data["name"]]["resource_path"], ")")
				in_object.set(var_data["name"], load(in_data[var_data["name"]]["resource_path"]))
			elif in_object.get(var_data["name"]) != null:
				load_resource(in_object.get(var_data["name"]), in_data[var_data["name"]])
		in_object.set(var_data["name"], in_data[var_data["name"]])



func call_save() -> void:
	var saved_nodes: Dictionary[NodePath, Variant] = {}
	var to_save_nodes: Array[Node] = Utils.get_all_children_whith_variable(get_tree().root, "saveable")
	for node: Node in to_save_nodes:
		print("Saved: ", node.name)
		var path: NodePath = node.get_path()
		saved_nodes[path] = save_node(node)
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
		load_node(node, save.saved_nodes[node_path])
		print("Loaded: ", node.name)
	await get_tree().create_timer(1.0).timeout
	RS.gain_offline_progress(save.time)
			
