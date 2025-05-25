@tool
extends Resource
class_name SkillData

enum Type { SMALL, MEDIUM, LARGE, WEAPON, TOOL }

signal on_value_changed()

@export_range(1, 3) var size: int = 1:
    get: return size
    set(value):
        size = value
        on_value_changed.emit()

@export var icon: Texture2D = null:
    get: return icon
    set(value):
        icon = value
        on_value_changed.emit()

@export var type: Array[Type] = []

@export var time: float = 0.0

@export var active_effects: Array[Skill_Effect] = []

@export var triggered_effects: Dictionary[Combat.Trigger, EffectList] = {}