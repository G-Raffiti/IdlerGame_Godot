@tool
extends Resource
class_name AutoSaveRes

static func save_obj(in_object: Object) -> Dictionary[String, Variant]:
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
				save_data[var_data["name"]] = save_obj(sub_object)
		else:
			# Save
			save_data[var_data["name"]] = in_object.get(var_data["name"])
	return save_data

func save() -> Dictionary[String, Variant]:
	return save_obj(self)

static func load_data_obj(in_object: Object, in_data: Dictionary[String, Variant]) -> void:
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
				load_data_obj(in_object.get(var_data["name"]), in_data[var_data["name"]])
		in_object.set(var_data["name"], in_data[var_data["name"]])

func load_data(in_data: Dictionary[String, Variant]) ->  void:
	load_data_obj(self, in_data)
