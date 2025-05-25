extends Resource
class_name Adventurer

enum CombatResource { GOLD, XP }

@export var max_hp: float
var hp: float
var shield: float
var poison: float
var burn: float

@export var level: int = 1
@export var reward: Dictionary[CombatResource, int] = {CombatResource.GOLD: 4, CombatResource.XP: 2}

@export var board: Array[SkillData] = []