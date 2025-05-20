@tool
extends Resource
class_name AutoSaveRes

func save_obj(in_object: Object) -> Dictionary[String, Variant]:
	var save_data: Dictionary[String, Variant] = {}
	for i: int in range(0, in_object.get_property_list().size(), 1):
		var var_data: Dictionary = in_object.get_property_list()[i]
		if var_data["name"].is_empty():
			continue
		if var_data["type"] == 24:
			if in_object.get(var_data["name"]) == null:
				save_data[var_data["name"]] = null
			else:
				save_data[var_data["name"]] = save_obj(in_object.get(var_data["name"]))
		else:
			save_data[var_data["name"]] = in_object.get(var_data["name"])
	return save_data

func save() -> Dictionary[String, Variant]:
	return save_obj(self)

func load_data_obj(in_object: Object, in_data: Dictionary[String, Variant]) -> void:
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
