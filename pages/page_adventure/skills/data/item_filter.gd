@tool
extends Resource
class_name ItemFilter

@export_group("Collection")
@export var filter_collection: bool = false
@export var collections: Array[SkillData.Collection] = []
@export_tool_button("Add All Collection") var btn_add_all_collections: Callable = add_all_collections
func add_all_collections() -> void:
    collections.clear()
    for e: SkillData.Collection in SkillData.Collection.MAX_ENUM:
        collections.append(e)
@export_tool_button("Reverse Collections") var btn_reverse_collections: Callable = reverse_collections
func reverse_collections() -> void:
    var old_collections: Array[SkillData.Collection] = collections.duplicate()
    collections.clear()
    for e: SkillData.Collection in SkillData.Collection.MAX_ENUM:
        if old_collections.has(e): continue
        collections.append(e)

@export_group("Size")
@export var filter_size: bool = false
enum Size { ALL, SMALL, MEDIUM, LARGE, MAX_ENUM }
@export var sizes: Array[Size] = []
@export_tool_button("Add All Size") var btn_add_all_sizes: Callable = add_all_sizes
func add_all_sizes() -> void:
    sizes.clear()
    for e: Size in Size.MAX_ENUM:
        sizes.append(e)
@export_tool_button("Reverse Sizes") var btn_reverse_sizes: Callable = reverse_sizes
func reverse_sizes() -> void:
    var old_sizes: Array[Size] = sizes.duplicate()
    sizes.clear()
    for e: Size in Size.MAX_ENUM:
        if old_sizes.has(e): continue
        sizes.append(e)

@export_group("Types")
@export var filter_type: bool = false
@export var types: Array[SkillData.Type] = []
@export_tool_button("Add All Types") var btn_add_all_types: Callable = add_all_types
func add_all_types() -> void:
    types.clear()
    for e: SkillData.Type in SkillData.Type.MAX_ENUM:
        types.append(e)
@export_tool_button("Reverse types") var btn_reverse_types: Callable = reverse_types
func reverse_types() -> void:
    var old_types: Array[SkillData.Type] = types.duplicate()
    types.clear()
    for e: SkillData.Type in SkillData.Type.MAX_ENUM:
        if old_types.has(e): continue
        types.append(e)

@export var filter_except_type: bool = false
@export var except_types: Array[SkillData.Type] = []
@export_tool_button("Add All Types") var btn_add_all_except_types: Callable = add_all_except_types
func add_all_except_types() -> void:
    types.clear()
    for e: SkillData.Type in SkillData.Type.MAX_ENUM:
        types.append(e)
@export_tool_button("Reverse types") var btn_reverse_except_types: Callable = reverse_except_types
func reverse_except_types() -> void:
    var old_types: Array[SkillData.Type] = types.duplicate()
    types.clear()
    for e: SkillData.Type in SkillData.Type.MAX_ENUM:
        if old_types.has(e): continue
        types.append(e)

@export_group("Tier")
@export var filter_by_tier: bool = false
@export var minimum_tier: SkillData.Tier = SkillData.Tier.NONE

func validate(in_item: SkillData) -> bool:
    if filter_collection:
        if not collections.has(in_item.collection): 
            return false
    
    if filter_size:
        if not sizes.has(Size.ALL):
            if not sizes.has(in_item.size as Size):
                return false
    
    if filter_type:
        var valid: bool = false
        for type: SkillData.Type in in_item.type:
            if types.has(type):
                valid = true
                break
        if not valid: 
            return false
    
    if filter_except_type:
        for type: SkillData.Type in in_item.type:
            if except_types.has(type):
                return false

    if filter_by_tier:
        if in_item.starting_tier > minimum_tier:
            return false
    
    return true