extends Resource
class_name ItemCurrentData

@export var data: SkillData = null
@export var outside_combat_stats: Dictionary = {}
@export var tier: SkillData.Tier = SkillData.Tier.NONE
@export var cooldown: float = -1.0
@export var ammo: int = -1
@export var max_ammo: int = -1
@export var cost: int = -1
@export var damage: int = -1
@export var heal: int = -1
@export var shield: int = -1
@export var burn: int = -1
@export var poison: int = -1

func init(in_data: SkillData, in_tier: SkillData.Tier) -> void:
    data = in_data
    tier = max(data.starting_tier, in_tier)

# extends Resource
# class_name ItemCurrentData

# signal on_tier_value_changed(in_new_value: SkillData.Tier, in_old_value: SkillData.Tier)

# @export var data: SkillData = null
# var outside_combat_stats: Dictionary = {}

# var tier: SkillData.Tier = SkillData.Tier.NONE:
#     set(value):
#         on_tier_value_changed.emit(value, tier)
#         value = tier

# var cooldown: StatFloat = StatFloat.new()
# var ammo: Stat = Stat.new()
# var max_ammo: Stat = Stat.new()
# var cost: Stat = Stat.new()
# var damage: Stat = Stat.new()
# var heal: Stat = Stat.new()
# var shield: Stat = Stat.new()
# var burn: Stat = Stat.new()
# var poison: Stat = Stat.new()

# func init(in_data: SkillData, in_tier: SkillData.Tier) -> void:
#     data = in_data
#     tier = max(data.starting_tier, in_tier)
#     var current_tier_index: int = tier - in_data.starting_tier
#     cooldown.base_value = 0.0 if in_data.cooldown.is_empty() else in_data.cooldown[min(in_data.cooldown.size() - 1, current_tier_index)]
#     max_ammo.base_value = 0 if in_data.ammo.is_empty() else in_data.ammo[min(in_data.ammo.size() - 1, current_tier_index)]
#     ammo.base_value = max_ammo.base_value
#     cost.base_value = 2 * data.size * in_tier
#     
		# for effect: Skill_Effect in data.active_effects:
		# 	effect.initialize_item(current,)


# class Stat:
#     signal on_value_changed(in_new_value: int)

#     var base_value: int = 0:
#         set(value):
#             base_value = value
#             call_deferred("update_value")
    
#     var multiplier: float = 1.0:
#         set(value):
#             multiplier = value
#             call_deferred("update_value")
    
#     var bonus_permanent: int = 0:
#         set(value):
#             bonus_permanent = value
#             call_deferred("update_value")
    
#     var bonus_temp: int = 0:
#         set(value):
#             bonus_temp = value
#             call_deferred("update_value")
    
#     var bonus_position: int = 0:
#         set(value):
#             bonus_position = value
#             call_deferred("update_value")

#     func get_value() -> int:
#         return int((base_value + bonus_permanent + bonus_temp + bonus_position) * multiplier)

#     func update_value() -> void:
#         on_value_changed.emit(get_value())

# class StatFloat:
#     signal on_value_changed(in_new_value: float)

#     var base_value: float = 0:
#         set(value):
#             base_value = value
#             call_deferred("update_value")
    
#     var multiplier: float = 1.0:
#         set(value):
#             multiplier = value
#             call_deferred("update_value")
    
#     var bonus_permanent: float = 0:
#         set(value):
#             bonus_permanent = value
#             call_deferred("update_value")
    
#     var bonus_temp: float = 0:
#         set(value):
#             bonus_temp = value
#             call_deferred("update_value")
    
#     var bonus_position: float = 0:
#         set(value):
#             bonus_position = value
#             call_deferred("update_value")

#     func get_value() -> float:
#         return (base_value + bonus_permanent + bonus_temp + bonus_position) * multiplier

#     func update_value() -> void:
#         on_value_changed.emit(get_value())