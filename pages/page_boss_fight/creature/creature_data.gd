@tool
extends Resource
class_name Creature_Data

@export var name: String = ""
@export var icon: Texture2D = null
@export_multiline var text: String = "Level X Rewards\n[b]Unlock: [/b]"

@export var hp: Vector2 = Vector2(1.0, 0)
@export var attack: Vector2 = Vector2(0.0, 0)
@export var attack_duration: Vector2 = Vector2(1.0, 0)
@export var defense: Vector2 = Vector2(0.0, 0)
@export var defense_duration: Vector2 = Vector2(1.0, 0)
@export var regen: Vector2 = Vector2(0.0, 0)

@export var resources_gained_on_killed: Dictionary[E.Res, Vector2]
