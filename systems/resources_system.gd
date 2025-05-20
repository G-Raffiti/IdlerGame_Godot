extends Node

signal on_current_boss_level_changed(in_level: int)

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
		resources[E.Res.ENERGY] = energy
		gold = ResourceManager.new()
		add_child(gold, true)
		resources[E.Res.GOLD] = gold
		regen = ResourceManager.new()
		add_child(regen, true)
		stats[E.Stats.REGEN] = regen
		hp = ResourceManager.new()
		add_child(hp, true)
		stats[E.Stats.HP] = hp
		attack = ResourceManager.new()
		add_child(attack, true)
		stats[E.Stats.ATTACK] = attack
		attack_duration = ResourceManager.new()
		add_child(attack_duration, true)
		stats[E.Stats.ATTACK_SPEED] = attack_duration
		defense = ResourceManager.new()
		add_child(defense, true)
		stats[E.Stats.DEFENSE] = defense
		defense_duration = ResourceManager.new()
		add_child(defense_duration, true)
		stats[E.Stats.DEFENSE_SPEED] = defense_duration

func add_resources(in_amount: Dictionary[E.Res, Vector2]) -> void:
	for type in in_amount:
		resources[type].add(in_amount[type])

func try_spend(in_amount: Dictionary[E.Res, Vector2]) -> bool:
	for type in in_amount:
		if Number.is_smaller(resources[type].get_available(), in_amount[type]):
			return false
	for type in in_amount:
		resources[type].add(Number.minus(in_amount[type]))
	return true

func try_use(in_amount: Dictionary[E.Res, Vector2]) -> bool:
	for type in in_amount:
		if Number.is_smaller(resources[type].get_available(), in_amount[type]):
			return false
	for type in in_amount:
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
