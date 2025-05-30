extends Resource
class_name Skill_Effect

enum Target { PLAYER_OWNER, PLAYER_ENEMY, PREVIOUS_ITEM, NEXT_ITEM, ADJACENTS, RANDOM_ADJACENT, RANDOM_OWNER_ITEM, RANDOM_ENEMY_ITEM, SELF }

@export var target: Target
@export var target_number: int

func activate(in_item_data: ItemCurrentData, in_index: int, in_player: Adventurer, in_player_board: Dictionary[int, SkillObject], in_enemy: Adventurer, in_enemy_board: Dictionary[int, SkillObject]) -> void:
	pass

func initialize_item(in_item_data: ItemCurrentData, in_current_tier: SkillData.Tier, in_previous_tier: SkillData.Tier) -> void:
	pass
