@tool
extends Node

@export var data: ParserData
@export var skills: Dictionary[String, SkillData]
@export_tool_button("Generate Skills From Data") var generate_button_callback: Callable = generate


@export_tool_button("Save Skills Data As Files") var save_button_callback: Callable = save_files

func generate() -> void:
    for item: Dictionary in data.data:
        var skill_data: SkillData
        if skills.has(item["name"]):
            skill_data = skills[item["name"]]
        else:
            skill_data = SkillData.new()
        skill_data.name = item["name"]
        if FileAccess.file_exists("res://BazzarDBParser/" + item["image"]):
            skill_data.icon = load("res://BazzarDBParser/" + item["image"])
        else:
            print("No Image for ", item["name"])
        skill_data.description = item["description"]
        skill_data.cooldown = []
        for cd: float in item["cooldown"]:
            skill_data.cooldown.append(cd)
        skill_data.ammo = []
        for ammu: int in item["ammo"]:
            skill_data.ammo.append(ammu)
        skill_data.type = []
        for type_str: String in item["type"]:
            skill_data.type.append(SkillData.get_type_from_string(type_str, item["name"]))
        match item["size"]:
            "Large": skill_data.size = 3
            "Medium": skill_data.size = 2
            "Small": skill_data.size = 1
        skill_data.cost = []
        for price: int in item["cost"]:
            skill_data.cost.append(price)
        skill_data.starting_tier = SkillData.get_tier_from_string(item["starting_tier"], item["name"])
        skill_data.collection = SkillData.get_collection_from_string(item["collection"], item["name"])
        skills[item["name"]] = skill_data

func save_files() -> void:
    for skill_name: String in skills:
        print("Saving ", skill_name, "...")
        if ResourceSaver.save(skills[skill_name], "res://pages/page_adventure/skills/skill_data/" + skill_name + ".tres") == 0:
            print("Saving ", skill_name, " Success")
            skills[skill_name] = ResourceLoader.load("res://pages/page_adventure/skills/skill_data/" + skill_name + ".tres")
        else:
            print("Saving ", skill_name, " FAIL")
        await get_tree().process_frame