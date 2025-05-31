@tool
extends Resource
class_name AdventureData

@export_group("Visual Data")
@export var item_rarity_borders: Dictionary[SkillData.Tier, Texture2D]
@export var player_portraits: Dictionary[SkillData.Collection, Texture2D]

@export_group("Items")
@export var load_only_items: SkillData.DevState = SkillData.DevState.ALL
@export var filter: ItemFilter
@export_tool_button("Load All Items") var btn_load_all_items: Callable = load_all_items
@export var all_items: Array[SkillData]

func load_all_items() -> void:
    print("loading... ")
    all_items.clear()
    var folder: DirAccess = DirAccess.open("res://pages/page_adventure/skills/skill_data/")
    for file_name: String in folder.get_files():
        var skill_data: SkillData = ResourceLoader.load("res://pages/page_adventure/skills/skill_data/" + file_name)
        print(skill_data.dev_state, load_only_items, SkillData.DevState.ALL)
        if load_only_items != SkillData.DevState.ALL and skill_data.dev_state != load_only_items:
            continue
        print("load " + file_name)
        if filter != null and not filter.validate(skill_data):
            continue
        all_items.append(skill_data)
