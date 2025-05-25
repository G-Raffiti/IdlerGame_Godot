extends Node

const saveable: bool = true
const save_exception: Array[String] = ["resources", "stats"]

signal on_current_boss_level_changed(in_level: int)
signal on_offline_progress_time_calculated(in_delta: Vector2)

var energy: ResourceManager
var gold: ResourceManager
var resources: Dictionary[E.Res, ResourceManager]

var hp: ResourceManager
var regen: ResourceManager
var attack: ResourceManager
var defense: ResourceManager
var attack_duration: ResourceManager
var defense_duration: ResourceManager
var stats: Dictionary[E.Stats, ResourceManager]

var current_boss_level: int = 0:
	set(value): 
		current_boss_level = value
		on_current_boss_level_changed.emit(value)

func _ready() -> void:
		energy = ResourceManager.new()
		add_child(energy, true)
		energy.name = "energy"
		resources[E.Res.ENERGY] = energy
		gold = ResourceManager.new()
		add_child(gold, true)
		gold.name = "gold"
		resources[E.Res.GOLD] = gold
		regen = ResourceManager.new()
		add_child(regen, true)
		regen.name = "regen"
		stats[E.Stats.REGEN] = regen
		hp = ResourceManager.new()
		add_child(hp, true)
		hp.name = "hp"
		stats[E.Stats.HP] = hp
		attack = ResourceManager.new()
		add_child(attack, true)
		attack.name = "attack"
		stats[E.Stats.ATTACK] = attack
		attack_duration = ResourceManager.new()
		add_child(attack_duration, true)
		attack_duration.name = "attack_duration"
		stats[E.Stats.ATTACK_SPEED] = attack_duration
		defense = ResourceManager.new()
		add_child(defense, true)
		defense.name = "defense"
		stats[E.Stats.DEFENSE] = defense
		defense_duration = ResourceManager.new()
		add_child(defense_duration, true)
		defense_duration.name = "defense_duration"
		stats[E.Stats.DEFENSE_SPEED] = defense_duration

func add_resources(in_amount: Dictionary[E.Res, Vector2]) -> void:
	for type: E.Res in in_amount:
		resources[type].add(in_amount[type])

func try_spend(in_amount: Dictionary[E.Res, Vector2]) -> bool:
	for type: E.Res in in_amount:
		if Number.is_smaller(resources[type].get_available(), in_amount[type]):
			return false
	for type: E.Res in in_amount:
		resources[type].add(Number.minus(in_amount[type]))
	return true

func try_use(in_amount: Dictionary[E.Res, Vector2]) -> bool:
	for type: E.Res in in_amount:
		if Number.is_smaller(resources[type].get_available(), in_amount[type]):
			return false
	for type: E.Res in in_amount:
		resources[type].use(in_amount[type])
	return true

func allocate_resources(in_resource_type: E.Res, in_allocator: ResourceAllocator, in_allocation: E.Allocation, in_amount: Vector2) -> void:
	var amount: Vector2
	match in_allocation:
		E.Allocation.ADD:
			amount = Number.min_num(resources[in_resource_type].get_available(), in_amount)
		E.Allocation.REMOVE:
			amount = Number.minus(Number.min_num(in_allocator.current_allocated, in_amount))
		E.Allocation.MAX:
			amount = Number.min_num(resources[in_resource_type].get_available(), Number.sub(in_allocator.maximum_allocated, in_allocator.current_allocated))
	if try_use({in_resource_type: amount}):
		in_allocator.allocate_resource(amount)

func add_stats(in_stat_type: E.Stats, in_amount: Vector2) -> void:
	stats[in_stat_type].add(in_amount)

func gain_offline_progress(in_last_save_time: Dictionary) -> void:
	var current_time: Dictionary = Time.get_datetime_dict_from_system()
	var delta_time_sec: Vector2 = \
		Number.add(Number.add(Number.add(Number.add(Number.add(\
			Number.mult(Vector2(current_time["year"] - in_last_save_time["year"], 0), Vector2(3.154, 7)), \
			Number.mult(Vector2(current_time["month"] - in_last_save_time["month"], 0), Vector2(2.628, 6))), \
			Number.mult(Vector2(current_time["day"] - in_last_save_time["day"], 0), Vector2(8.6400, 4))), \
			Number.mult(Vector2(current_time["hour"] - in_last_save_time["hour"], 0), Vector2(3.6, 3))), \
			Number.mult(Vector2(current_time["minute"] - in_last_save_time["minute"], 0), Vector2(6, 1))), \
			Vector2(current_time["second"] - in_last_save_time["second"], 0))
	if Number.is_smaller(delta_time_sec, Vector2(6.0, 1)):
		return
	print(Number.to_str_time(delta_time_sec))
	delta_time_sec = Number.mult(delta_time_sec, Settings.offline_production_factor)
	energy.add(Number.mult(energy.get_production(), delta_time_sec))
	on_offline_progress_time_calculated.emit(delta_time_sec)
