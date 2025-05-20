extends Control
class_name Manager

#region    --- Pages ---
var excavation: PageExcavation
var central: Central
var training: PageTraining
var boss_fight: PageBossFight
#endregion --- Pages ---

func _ready() -> void:
	await get_tree().physics_frame
	initialize_input()
	initialize_energy_bar()
	initialize_gold()
	SignalBus.on_manager_ready.emit(self)
	initialize_stats()

#region    --- Input ---
@export var input: LineEdit
var input_value: Vector2


func initialize_input() -> void:
	input.text_submitted.connect(update_input_value)
	input_value = Number.from_int(input.text.to_int())


func update_input_value(in_text: String) -> void:
	input_value = Number.from_int(in_text.to_int())

#endregion --- Input ---

#region    --- Energy ---
@export_group("Energy")
@export var energy_bar: ProgressBarButton
signal on_reset_energy_allocation()

func initialize_energy_bar() -> void:
	RS.energy.on_maximum_amount_changed.connect(update_energy_bar)
	RS.energy.on_amount_changed.connect(update_energy_bar)
	RS.energy.on_amount_used_changed.connect(update_energy_bar)
	RS.energy.on_production_changed.connect(update_energy_bar)
	energy_bar.pressed.connect(reset_energy_allocation)
	update_energy_bar()


func update_energy_bar() -> void:
	energy_bar.update_progress(RS.energy.get_percent())
	energy_bar.text_value = "[b]Energy:[/b] " + Number.to_str(RS.energy.get_available()) + \
		" Idle\n" + Number.to_str(RS.energy.amount) + " / " + Number.to_str(RS.energy.maximum_amount) + \
		" (+" + Number.to_str(RS.energy.get_production()) + "/s)"

	energy_bar.tooltip_base_text = "[b][color=pale_green]Energy[/color][/b]
Can be used in the Excavation to increase [color=gold]Button[/color] efficiency
or to auto click.

[b]Click here[/b] to reset all energy atribution and STOP all productions."

func reset_energy_allocation() -> void:
	on_reset_energy_allocation.emit()
	RS.energy.amount_used = Vector2.ZERO

func add_energy_to_allocator(in_allocator: ResourceAllocator, in_allocation: E.Allocation) -> void:
	RS.allocate_resources(E.Res.ENERGY, in_allocator, in_allocation, input_value)

#endregion --- Energy ---

#region    --- Gold ---
@export_group("Gold")
@export var gold_bar: ProgressBarButton


func initialize_gold() -> void:
	RS.gold.on_maximum_amount_changed.connect(update_gold_bar)
	RS.gold.on_amount_changed.connect(update_gold_bar)
	RS.gold.on_amount_used_changed.connect(update_gold_bar)
	RS.gold.on_production_changed.connect(update_gold_bar)
	update_energy_bar()
	gold_bar.pressed.connect(increase_max_gold)


func update_gold_bar() -> void:
	gold_bar.update_progress(RS.gold.get_percent())
	gold_bar.text_value = "[b]Gold:[/b]\n" + \
	Number.to_str(RS.gold.amount) + " / " + Number.to_str(RS.gold.maximum_amount) + \
	" (+" + Number.to_str(excavation.total_per_click[E.Res.GOLD]) + "/c)"
	gold_bar.tooltip_base_text = "[b][color=gold]Gold[/color]:[/b]
Can be used in the Central to increase acces to [b][color=pale_green]Energy[/color][/b]

[b]Click here[/b] to increase the [color=gold][b]Gold[/b][/color] storage capacity.
	" + Number.to_str(Number.mult_float(RS.gold.maximum_amount, 0.9)) + " [color=gold][b]Gold[/b][/color] (90% of current maximum)"


func increase_max_gold() -> void:
	var cost: Vector2 = Number.mult_float(RS.gold.maximum_amount, 0.9)
	if not RS.try_spend({E.Res.GOLD: cost}):
		return
	RS.gold.maximum_amount = Number.mult_float(RS.gold.maximum_amount, 1.1)


#endregion --- Gold ---

#region    --- Stats ---
@export_group("Stats")
@export var hp_bar: ProgressBar
@export var hp_text: RichTextLabel
@export var attack_bar: ProgressBar
@export var attack_text: RichTextLabel
@export var defense_bar: ProgressBar
@export var defense_text: RichTextLabel

func initialize_stats() -> void:
	RS.hp.on_amount_changed.connect(_update_text_hp)
	RS.attack.on_amount_changed.connect(_update_text_attack)
	RS.defense.on_amount_changed.connect(_update_text_defense)
	RS.regen.on_amount_changed.connect(_update_hp_regen)
	_update_text_attack()
	_update_text_defense()

func _update_text_hp() -> void:
	hp_text.text = Number.to_str(RS.hp.amount) + " / " + Number.to_str(RS.hp.maximum_amount) + " [color=red]HP[/color]"
	hp_bar.value = Number.to_float(Number.div(RS.hp.amount, RS.hp.maximum_amount))

func _update_text_attack() -> void:
	attack_text.text = "[b][color=tomato]Attack[/color][/b]\n" + Number.to_str(RS.attack.amount)
	var next_boss: Creature_Data = boss_fight.get_boss_stats()
	if next_boss == null:
		attack_bar.value = 1
		return
	attack_bar.value = Number.to_float(Number.div(Number.div(RS.attack.amount, RS.attack_duration.get_total_with_bonus()), Number.div(next_boss.defense, next_boss.defense_duration)))

func _update_text_defense() -> void:
	defense_text.text = "[b][color=sky_blue]Defense[/color][/b]\n" + Number.to_str(RS.defense.amount)
	var next_boss: Creature_Data = boss_fight.get_boss_stats()
	if next_boss == null:
		defense_bar.value = 1
		return
	defense_bar.value = Number.to_float(Number.div(Number.div(RS.defense.amount, RS.defense_duration.get_total_with_bonus()), Number.div(next_boss.attack, next_boss.attack_duration)))

var id_regen: int = -1
func _update_hp_regen() -> void:
	if id_regen == -1:
		id_regen = RS.hp.add_flat_bonus(RS.regen.get_total_with_bonus())
	else:
		RS.hp.update_bonus(id_regen, RS.regen.get_total_with_bonus())

#endregion --- Stats ---
