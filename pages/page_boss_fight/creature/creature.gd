extends CenterContainer
class_name Creature

signal on_attack_done(in_value: Vector2)
signal on_dead()

@onready var creature_name_node: RichTextLabel = %CreatureName
@onready var icon_node: TextureRect = %Icon
@onready var hp_progress_bar: ProgressBar = %HP_ProgressBar
@onready var def_progress_bar: ProgressBar = %Def_ProgressBar
@onready var hp_rich_text_label: RichTextLabel = %HP_RichTextLabel
@onready var attack_bar: SkillBar = %AttackBar
@onready var regen_bar: SkillBar = %RegenBar
@onready var defense_bar: SkillBar = %DefenseBar
@onready var skill_container: VBoxContainer = %SkillContainer

@export var creature_name: String:
	set(value):
		creature_name = value
		if not is_inside_tree(): return
		creature_name_node.text = value

@export var icon: Texture2D:
	set(value):
		icon = value
		if not is_inside_tree(): return
		icon_node.texture = value

var hp_max: Vector2
var hp: Vector2:
	set(value):
		hp = value
		if not is_inside_tree(): return
		hp_progress_bar.value = Number.to_float(Number.div(value, hp_max))
		_update_hp_text()
var shield: Vector2:
	set(value):
		shield = value
		if not is_inside_tree(): return
		def_progress_bar.value = 1.0 if Number.is_greater_or_equal(shield, hp_max) else Number.to_float(Number.div(value, hp_max))
		_update_hp_text()
var attack: Vector2:
	set(value):
		attack = value
		if not is_inside_tree(): return
		_update_attack_text()
var attack_duration: Vector2:
	set(value):
		attack_duration = value
		if not is_inside_tree(): return
		attack_bar.set_duration(value)
		_update_attack_text()
var defense: Vector2:
	set(value):
		defense = value
		if not is_inside_tree(): return
		_update_defense_text()
var defense_duration: Vector2:
	set(value):
		defense_duration = value
		if not is_inside_tree(): return
		defense_bar.set_duration(value)
		_update_defense_text()
var regen: Vector2:
	set(value):
		regen = value
		if not is_inside_tree(): return
		_update_regen_text()

func _ready() -> void:
	attack_bar.initialize()
	regen_bar.initialize()
	defense_bar.initialize()
	regen_bar.set_duration(Vector2(1.0, 0))
	attack_bar.on_bar_filled.connect(_on_attack_tick)
	regen_bar.on_bar_filled.connect(_on_regen_tick)
	defense_bar.on_bar_filled.connect(_on_defense_tick)

func take_hit(in_damage: Vector2) -> void:
	in_damage = Number.sub(in_damage, shield)
	if in_damage.x < 0:
		shield = Number.minus(in_damage)
		return
	shield = Vector2(0.0, 0)
	hp = Number.clamp(Number.sub(hp, in_damage), Vector2(0.0, 0), hp_max)
	if Number.is_zero(hp):
		on_dead.emit()

func _update_attack_text() -> void:
	attack_bar.set_text("[b][color=tomato]Attack[/color]:[/b] " + Number.to_str(Number.div(attack, attack_duration)) + "/s")
	attack_bar.tooltip_text = "[b]Basic [color=tomato]Attack[/color][/b]:\nDeals %s [b][color=tomato]Damage[/color][/b] to the enemy every %s" % [Number.to_str(attack), Number.to_str_time(attack_duration)]

func _update_regen_text() -> void:
	regen_bar.set_text("[b][color=green]Regen[/color]:[/b] +" + Number.to_str(regen) + "/s")
	regen_bar.tooltip_text = "[b]Basic [color=green]Regen[/color][/b]:\n[b][color=green]Heals[/color][/b] %s [color=red]HP[/color] every 1.00s" % Number.to_str(regen)

func _update_defense_text() -> void:
	defense_bar.set_text("[b][color=sky_blue]Defense[/color]:[/b] +" + Number.to_str(Number.div(defense, defense_duration)) + "/s")
	defense_bar.tooltip_text = "[b]Basic [color=sky_blue]Shield[/color][/b]:\nApply %s [b][color=sky_blue]Defense[/color][/b] to your [b][color=red]HP[/color][/b] every %s" % [Number.to_str(defense), Number.to_str_time(defense_duration)]

func _update_hp_text() -> void:
	hp_rich_text_label.text = Number.to_str(hp) + " / " + Number.to_str(hp_max) + " [color=red]HP[/color]\n+" +\
	Number.to_str(shield) + " [color=sky_blue]Defense[/color]"

func _on_attack_tick() -> void:
	on_attack_done.emit(attack)

func _on_regen_tick() -> void:
	hp = Number.min_num(hp_max, Number.add(hp, regen))

func _on_defense_tick() -> void:
	shield = Number.add(shield, defense)

func initialize_creature(in_data: Creature_Data) -> void:
	creature_name = in_data.name if not in_data.name.is_empty() else creature_name
	icon = in_data.icon if in_data.icon != null else icon
	hp_max = in_data.hp
	hp = hp_max
	attack_duration = in_data.attack_duration
	attack = in_data.attack
	defense = in_data.defense
	defense_duration = in_data.defense_duration
	regen = in_data.regen
	shield = Vector2(0.0, 0)

func start() -> void:
	attack_bar.start()
	defense_bar.start()
	regen_bar.start()

func stop() -> void:
	attack_bar.stop()
	defense_bar.stop()
	regen_bar.stop()
