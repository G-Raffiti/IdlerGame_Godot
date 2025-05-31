@tool
extends Button
class_name SkillObject

const save_excception: Array[String] = ["current", "data", "_started", "paused", "time", "time_scale", "outside_combat_stats"]
@onready var visual_data: AdventureData = preload("uid://b7kbibmnhimhg")

signal on_activate(in_index: int, in_skill_object: SkillObject)

@export var current: ItemCurrentData = ItemCurrentData.new():
	get: return current
	set(value):
		if value == null:
			current = ItemCurrentData.new()
			return
		else:
			current = value
			if value.data != null:
				_on_data_value_changed()

@export var data: SkillData:
	get: return current.data
	set(value):
		current.data = value
		if value == null:
			return
		_on_data_value_changed()

var _started: bool = false
var paused: bool = false
var time: float = 0.0
var time_scale: float = 1.0

# Display
@onready var texture: TextureRect = %"TextureRect" #
@onready var time_bar: ProgressBar = %"time_bar" #
@onready var border: NinePatchRect = %"NinePatchRect" #

# Reaction
@onready var haste: AdventureSkillObjectNumber = %"NumHaste"
@onready var freez: AdventureSkillObjectNumber = %"NumFreez"
@onready var slow: AdventureSkillObjectNumber = %"NumSlow"
@onready var cost: AdventureSkillObjectNumber = %"NumCost"
@onready var ammunition_container: BoxContainer = %"Ammunitions"

# Stats
@onready var damage: AdventureSkillObjectNumber = %"NumDamage"
@onready var heal: AdventureSkillObjectNumber = %"NumHeal"
@onready var shield: AdventureSkillObjectNumber = %"NumShield"
@onready var burn: AdventureSkillObjectNumber = %"NumBurn"
@onready var poison: AdventureSkillObjectNumber = %"NumPoison"


func _on_data_value_changed() -> void:
	if not is_inside_tree(): return
	if current == null: return
	current_tier = SkillData.Tier.NONE
	current_cooldown = -1.0
	current_ammo = -1
	max_ammo = -1
	current_cost = -1
	current.damage = -1
	current.heal = -1
	current.shield = -1
	current.burn = -1
	current.poison = -1
	if data == null: return

	# Size
	custom_minimum_size.x = 69 * data.size + (data.size - 1) * 4
	size.x = custom_minimum_size.x
	size.y = 0
	position = Vector2.ZERO

	# Icon
	texture.texture = data.icon
	get_tier()
	get_cooldown()
	get_ammo()
	get_cost()
	current_damage = current_damage
	current_heal = current_heal
	current_shield = current_shield
	current_burn = current_burn
	current_poison = current_poison

func _activate() -> void:
	on_activate.emit(get_parent().index, self)

func start() -> void:
	current.outside_combat_stats = SaveLoadSystem.save_node(self)
	get_tier()
	get_cooldown()
	get_ammo()
	get_cost()
	current_damage = current_damage
	current_heal = current_heal
	current_shield = current_shield
	current_burn = current_burn
	current_poison = current_poison
	_started = true

func stop() -> void:
	_started = false
	time = 0


func end_combat() -> void:
	SaveLoadSystem.load_node(self, current.outside_combat_stats)

func _ready() -> void:
	time_bar.value = 0.0

func _process(in_delta: float) -> void:
	if not _started: return
	if paused: return
	time += in_delta * time_scale
	time_bar.value = time
	if time >= get_cooldown():
		if get_max_ammo() > 0:
			if get_ammo() <= 0:
				paused = true
				return
			current_ammo -= 1
		time = 0.0
		_activate()

@export var current_tier: SkillData.Tier = SkillData.Tier.NONE:
	get: return current.tier
	set(value):
		current.tier = value
		if not is_inside_tree(): return
		border.texture = visual_data.item_rarity_borders[value]
func get_tier() -> int:
	if current_tier == SkillData.Tier.NONE:
		current_tier = data.starting_tier
	return int(current_tier - data.starting_tier)

@export var current_cooldown: float = -1:
	get: return current.cooldown
	set(value):
		current.cooldown = value
		if not is_inside_tree(): return
		time_bar.max_value = value
		time_bar.visible = value > 0
		paused = value <= 0
func get_cooldown() -> float:
	if current_cooldown == -1:
		if data.cooldown.is_empty():
			current_cooldown = 0.0
			return 0.0
		current_cooldown = data.cooldown[get_tier()]
	return current_cooldown

@export var current_ammo: int = -1:
	get: return current.ammo
	set(value):
		value = min(value, get_max_ammo())
		current.ammo = value
		if not is_inside_tree(): return
		while value > ammunition_container.get_child_count():
			ammunition_container.add_child(ammunition_container.get_child(0).duplicate())
		for i: int in ammunition_container.get_child_count():
			ammunition_container.get_child(i).visible = i < value
		if current.ammo == 0 and value > 0:
			paused = false
func get_ammo() -> int:
	if current_ammo == -1:
		if data.ammo.is_empty():
			current_ammo = 0
			return 0
		current_ammo = data.ammo[get_tier()]
	return current_ammo
@export var max_ammo: int = -1:
	get: return current.max_ammo
	set(value):
		current.max_ammo = value
func get_max_ammo() -> int:
	if max_ammo == -1:
		if data == null:
			return 0
		if data.ammo.is_empty():
			max_ammo = 0
			return 0
		max_ammo = data.ammo[get_tier()]
	return max_ammo

@export var current_cost: int = -1:
	get: return current.cost
	set(value):
		current.cost = value
		if not is_inside_tree(): return
		cost.set_value(value)
func get_cost() -> int:
	if current_cost == -1:
		current_cost = data.size * 2 * int(current_tier)
	return current_cost

func on_frozen(in_time: float) -> void:
	paused = true
	freez.on_timer_ends.connect(func() -> void: paused = false, Object.CONNECT_ONE_SHOT)
	freez.start_timer(in_time)

func on_hasted(in_time: float) -> void:
	if time_scale <= 1.0:
		time_scale = 1.0 if time_scale < 1.0 else 2.0
	haste.on_timer_ends.connect(func() -> void: time_scale = 1.0 if time_scale > 1.0 else 0.5, Object.CONNECT_ONE_SHOT)
	haste.set_timer(in_time)

func on_slowed(in_time: float) -> void:
	if time_scale <= 1.0:
		time_scale = 1.0 if time_scale > 1.0 else 0.5
	slow.on_timer_ends.connect(func() -> void: time_scale = 1.0 if time_scale < 1.0 else 2.0, Object.CONNECT_ONE_SHOT)
	slow.set_timer(in_time)

@export var current_damage: int = -1:
	get: return current.damage
	set(value):
		value = max(0.0, value)
		current.damage = value
		if not is_inside_tree(): return
		damage.set_value(value)

@export var current_heal: int = -1:
	get: return current.heal
	set(value):
		value = max(0.0, value)
		current.heal = value
		if not is_inside_tree(): return
		heal.set_value(value)

@export var current_shield: int = -1:
	get: return current.shield
	set(value):
		value = max(0.0, value)
		current.shield = value
		if not is_inside_tree(): return
		shield.set_value(value)

@export var current_burn: int = -1:
	get: return current.burn
	set(value):
		value = max(0.0, value)
		current.burn = value
		if not is_inside_tree(): return
		burn.set_value(value)

@export var current_poison: int = -1:
	get: return current.poison
	set(value):
		value = max(0.0, value)
		current.poison = value
		if not is_inside_tree(): return
		poison.set_value(value)
