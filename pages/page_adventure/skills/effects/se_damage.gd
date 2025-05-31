extends Skill_Effect
class_name SE_Damage

@export var damage_at_tier: Dictionary[SkillData.Tier, int] = {
	SkillData.Tier.BRONZE: 0,
	SkillData.Tier.SILVER: 0,
	SkillData.Tier.GOLD: 0,
	SkillData.Tier.DIAMOND: 0,
}

func activate(in_item_data: ItemCurrentData, in_index: int, in_player: Adventurer, in_player_board: Dictionary[int, SkillObject], in_enemy: Adventurer, in_enemy_board: Dictionary[int, SkillObject]) -> void:
	in_enemy.take_damage(in_item_data.damage)

func initialize_item(in_item_data: ItemCurrentData, in_current_tier: SkillData.Tier, in_previous_tier: SkillData.Tier) -> void:
	in_item_data.damage += damage_at_tier[in_current_tier] - damage_at_tier[in_previous_tier]