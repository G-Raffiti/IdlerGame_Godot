extends Node

@export_group("Productions")

@export_group("Productions/Energy")
@export var energy_start_amount: Vector2
@export var max_energy_start_amount: Vector2
@export var production_energy_start_amount: Vector2
@export var tick_duration_energy_start_amount: Vector2

@export_group("Productions/Gold")
@export var gold_start_amount: Vector2
@export var max_gold_start_amount: Vector2
@export var production_gold_start_amount: Vector2
@export var tick_duration_gold_start_amount: Vector2

@export_group("Stats")
@export var hp_start_amount: Vector2
@export var regen_start_amount: Vector2
@export var attack_start_amount: Vector2
@export var attack_duration_start_amount: Vector2
@export var defense_start_amount: Vector2
@export var defense_duration_start_amount: Vector2

func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	RS.energy.load(energy_start_amount, max_energy_start_amount, production_energy_start_amount, tick_duration_energy_start_amount)
	RS.gold.load(gold_start_amount, max_gold_start_amount, production_gold_start_amount, tick_duration_gold_start_amount)

	RS.hp.load(hp_start_amount, hp_start_amount, Vector2(0.0, 0), Vector2(1.0, 0))
	RS.regen.load(regen_start_amount, Vector2(-1.0, 0), Vector2(0.0, 0), Vector2(1.0, 0))
	RS.attack.load(attack_start_amount, Vector2(-1.0, 0), Vector2(0.0, 0), Vector2(1.0, 0))
	RS.attack_duration.load(attack_duration_start_amount, Vector2(-1.0, 0), Vector2(0.0, 0), Vector2(1.0, 0))
	RS.defense.load(defense_start_amount, Vector2(-1.0, 0), Vector2(0.0, 0), Vector2(1.0, 0))
	RS.defense_duration.load(defense_duration_start_amount, Vector2(-1.0, 0), Vector2(0.0, 0), Vector2(1.0, 0))
	
	RS.current_boss_level = 0
