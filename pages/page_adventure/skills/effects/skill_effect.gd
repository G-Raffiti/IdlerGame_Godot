extends Resource
class_name Skill_Effect

enum Target { PLAYER_OWNER, PLAYER_ENEMY, PREVIOUS_SKILL, NEXT_SKILL, NEIGHBOURS, RANDOM_OWNER_SKILL, RANDOM_ENEMY_SKILL, SELF }

@export var target: Target
@export var target_number: int

func activate(in_skill_data: SkillData, in_index: int, in_player: Adventurer, in_player_board: Dictionary[int, SkillObject], in_enemy: Adventurer, in_enemy_board: Dictionary[int, SkillObject]) -> void:
    pass