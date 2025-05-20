extends PageBase
class_name PageTraining

@export_group("Attack Skills")
@export_group("Attack Skills/Basic Attack (+)")
@export var basic_attack_allocator: ResourceAllocator
@export var basic_attack_allocator_data: ResourceAllocator_Data
@export var basic_attack_amount: Vector2
@export_group("Attack Skills/Advanced Attack (+)")
@export var advanced_attack_allocator: ResourceAllocator
@export var advanced_attack_allocator_data: ResourceAllocator_Data
@export var advanced_attack_amount: Vector2
@export_group("Attack Skills/Master Attack (+)")
@export var master_attack_allocator: ResourceAllocator
@export var master_attack_allocator_data: ResourceAllocator_Data
@export var master_attack_amount: Vector2
@export_group("Attack Skills/Increase Attack (+%)")
@export var increase_attack_allocator: ResourceAllocator
@export var increase_attack_allocator_data: ResourceAllocator_Data
@export var increase_attack_amount: Vector2
@export_group("Attack Skills/Attack Speed (+%)")
@export var increase_attack_speed_allocator: ResourceAllocator
@export var increase_attack_speed_allocator_data: ResourceAllocator_Data
@export var increase_attack_speed_amount: Vector2 ## attack duration multiplier (ex: 0.95 ~= +5% Attack Speed)

@export_group("Defense Skills")
@export_group("Defense Skills/Basic Defense")
@export var basic_defense_allocator: ResourceAllocator
@export var basic_defense_allocator_data: ResourceAllocator_Data
@export var basic_defense_amount: Vector2
@export_group("Defense Skills/Advanced Defense (+)")
@export var advanced_defense_allocator: ResourceAllocator
@export var advanced_defense_allocator_data: ResourceAllocator_Data
@export var advanced_defense_amount: Vector2
@export_group("Defense Skills/Master Defense (+)")
@export var master_defense_allocator: ResourceAllocator
@export var master_defense_allocator_data: ResourceAllocator_Data
@export var master_defense_amount: Vector2
@export_group("Defense Skills/Increase Defense (+%)")
@export var increase_defense_allocator: ResourceAllocator
@export var increase_defense_allocator_data: ResourceAllocator_Data
@export var increase_defense_amount: Vector2
@export_group("Defense Skills/Defense Speed (+%)")
@export var increase_defense_speed_allocator: ResourceAllocator
@export var increase_defense_speed_allocator_data: ResourceAllocator_Data
@export var increase_defense_speed_amount: Vector2 ## defense duration multiplier (ex: 0.95 ~= +5% Defense Speed)

@export_group("HP Skills")
@export_group("HP Skills/Basic HP")
@export var basic_hp_allocator: ResourceAllocator
@export var basic_hp_allocator_data: ResourceAllocator_Data
@export var basic_hp_amount: Vector2

func register_to_manager(in_manager: Manager) -> void:
	super.register_to_manager(in_manager)
	in_manager.training = self
	initialize_data()

func initialize_data() -> void:
	basic_attack_allocator.init_data(basic_attack_allocator_data)
	basic_attack_allocator.on_change_amount_pressed.connect(manager.add_energy_to_allocator)
	basic_attack_allocator.on_bar_filled.connect(func(): _add_stat(E.Stats.ATTACK, basic_attack_amount))
	
	advanced_attack_allocator.init_data(advanced_attack_allocator_data)
	advanced_attack_allocator.on_change_amount_pressed.connect(manager.add_energy_to_allocator)
	advanced_attack_allocator.on_bar_filled.connect(func(): _add_stat(E.Stats.ATTACK, advanced_attack_amount))
	
	master_attack_allocator.init_data(master_attack_allocator_data)
	master_attack_allocator.on_change_amount_pressed.connect(manager.add_energy_to_allocator)
	master_attack_allocator.on_bar_filled.connect(func(): _add_stat(E.Stats.ATTACK, master_attack_amount))
	
	increase_attack_allocator.init_data(increase_attack_allocator_data)
	increase_attack_allocator.on_change_amount_pressed.connect(manager.add_energy_to_allocator)
	increase_attack_allocator.on_bar_filled.connect(func(): _increase_stat(E.Stats.ATTACK, increase_attack_amount))
	
	increase_attack_speed_allocator.init_data(increase_attack_speed_allocator_data)
	increase_attack_speed_allocator.on_change_amount_pressed.connect(manager.add_energy_to_allocator)
	increase_attack_speed_allocator.on_bar_filled.connect(func(): _mult_attack_duration(increase_attack_speed_amount))
	
	basic_defense_allocator.init_data(basic_defense_allocator_data)
	basic_defense_allocator.on_change_amount_pressed.connect(manager.add_energy_to_allocator)
	basic_defense_allocator.on_bar_filled.connect(func(): _add_stat(E.Stats.DEFENSE, basic_defense_amount))
	
	advanced_defense_allocator.init_data(advanced_defense_allocator_data)
	advanced_defense_allocator.on_change_amount_pressed.connect(manager.add_energy_to_allocator)
	advanced_defense_allocator.on_bar_filled.connect(func(): _add_stat(E.Stats.DEFENSE, advanced_defense_amount))
	
	master_defense_allocator.init_data(master_defense_allocator_data)
	master_defense_allocator.on_change_amount_pressed.connect(manager.add_energy_to_allocator)
	master_defense_allocator.on_bar_filled.connect(func(): _add_stat(E.Stats.DEFENSE, master_defense_amount))
	
	increase_defense_allocator.init_data(increase_defense_allocator_data)
	increase_defense_allocator.on_change_amount_pressed.connect(manager.add_energy_to_allocator)
	increase_defense_allocator.on_bar_filled.connect(func(): _increase_stat(E.Stats.DEFENSE, increase_defense_amount))
	
	increase_defense_speed_allocator.init_data(increase_defense_speed_allocator_data)
	increase_defense_speed_allocator.on_change_amount_pressed.connect(manager.add_energy_to_allocator)
	increase_defense_speed_allocator.on_bar_filled.connect(func(): _mult_defense_duration(increase_attack_speed_amount))
	
	basic_hp_allocator.init_data(basic_hp_allocator_data)
	basic_hp_allocator.on_change_amount_pressed.connect(manager.add_energy_to_allocator)
	basic_hp_allocator.on_bar_filled.connect(_add_hp_max)
	
	RS.attack.on_global_value_changed.connect(_update_tooltip_attack)
	RS.defense.on_global_value_changed.connect(_update_tooltip_defense)
	_update_tooltip_attack()
	_update_tooltip_defense()
	
	manager.on_reset_energy_allocation.connect(reset_energy_allocation)


func _add_stat(in_stat_type: E.Stats, in_amount: Vector2) -> void:
	RS.add_stats(in_stat_type, in_amount)

func _increase_stat(in_stat_type: E.Stats, in_increase_amount) -> void:
	RS.stats[in_stat_type].add_global_value_inc(in_increase_amount)

func _mult_attack_duration(in_mult_amount: Vector2) -> void:
	RS.attack_duration.add_mult_bonus(in_mult_amount)

func _mult_defense_duration(in_mult_amount: Vector2) -> void:
	RS.defense_duration.add_mult_bonus(in_mult_amount)

func _add_hp_max() -> void:
	RS.hp.maximum_amount = Number.add(RS.hp.maximum_amount, basic_hp_amount)
	RS.hp.add(basic_hp_amount)

func _update_tooltip_attack() -> void:
	basic_attack_allocator.dynamic_tooltip_value = "+" + Number.to_str(Number.mult(RS.attack.total_global_value_inc, basic_attack_amount)) + " [b][color=tomato]Attack[/color][/b] / level"
	advanced_attack_allocator.dynamic_tooltip_value = "+" + Number.to_str(Number.mult(RS.attack.total_global_value_inc, advanced_attack_amount)) + " [b][color=tomato]Attack[/color][/b] / level"
	master_attack_allocator.dynamic_tooltip_value = "+" + Number.to_str(Number.mult(RS.attack.total_global_value_inc, master_attack_amount)) + " [b][color=tomato]Attack[/color][/b] / level"

func _update_tooltip_defense() -> void:
	basic_defense_allocator.dynamic_tooltip_value = "+" + Number.to_str(Number.mult(RS.defense.total_global_value_inc, basic_defense_amount)) + " [b][color=sky_blue]Defense[/color][/b] / level"
	advanced_defense_allocator.dynamic_tooltip_value = "+" + Number.to_str(Number.mult(RS.defense.total_global_value_inc, advanced_defense_amount)) + " [b][color=sky_blue]Defense[/color][/b] / level"
	master_defense_allocator.dynamic_tooltip_value = "+" + Number.to_str(Number.mult(RS.defense.total_global_value_inc, master_defense_amount)) + " [b][color=sky_blue]Defense[/color][/b] / level"

func reset_energy_allocation() -> void:
	basic_attack_allocator.allocate_resource(Number.minus(basic_attack_allocator.current_allocated))
	advanced_attack_allocator.allocate_resource(Number.minus(advanced_attack_allocator.current_allocated))
	master_attack_allocator.allocate_resource(Number.minus(master_attack_allocator.current_allocated))
	increase_attack_allocator.allocate_resource(Number.minus(increase_attack_allocator.current_allocated))
	increase_attack_speed_allocator.allocate_resource(Number.minus(increase_attack_speed_allocator.current_allocated))
	basic_defense_allocator.allocate_resource(Number.minus(basic_defense_allocator.current_allocated))
	advanced_defense_allocator.allocate_resource(Number.minus(advanced_defense_allocator.current_allocated))
	master_defense_allocator.allocate_resource(Number.minus(master_defense_allocator.current_allocated))
	increase_defense_allocator.allocate_resource(Number.minus(increase_defense_allocator.current_allocated))
	increase_defense_speed_allocator.allocate_resource(Number.minus(increase_defense_speed_allocator.current_allocated))
	basic_hp_allocator.allocate_resource(Number.minus(basic_hp_allocator.current_allocated))

func _on_current_boss_level_changed(in_current_boss_level) -> void:
	basic_attack_allocator.set_unlocked("Unlocked at Boss Level " + str(basic_attack_allocator_data.unlock_level), basic_attack_allocator_data.unlock_level <= in_current_boss_level)
	advanced_attack_allocator.set_unlocked("Unlocked at Boss Level " + str(advanced_attack_allocator_data.unlock_level), advanced_attack_allocator_data.unlock_level <= in_current_boss_level)
	master_attack_allocator.set_unlocked("Unlocked at Boss Level " + str(master_attack_allocator_data.unlock_level), master_attack_allocator_data.unlock_level <= in_current_boss_level)
	increase_attack_allocator.set_unlocked("Unlocked at Boss Level " + str(increase_attack_allocator_data.unlock_level), increase_attack_allocator_data.unlock_level <= in_current_boss_level)
	increase_attack_speed_allocator.set_unlocked("Unlocked at Boss Level " + str(increase_attack_speed_allocator_data.unlock_level), increase_attack_speed_allocator_data.unlock_level <= in_current_boss_level)
	basic_defense_allocator.set_unlocked("Unlocked at Boss Level " + str(basic_defense_allocator_data.unlock_level), basic_defense_allocator_data.unlock_level <= in_current_boss_level)
	advanced_defense_allocator.set_unlocked("Unlocked at Boss Level " + str(advanced_defense_allocator_data.unlock_level), advanced_defense_allocator_data.unlock_level <= in_current_boss_level)
	master_defense_allocator.set_unlocked("Unlocked at Boss Level " + str(master_defense_allocator_data.unlock_level), master_defense_allocator_data.unlock_level <= in_current_boss_level)
	increase_defense_allocator.set_unlocked("Unlocked at Boss Level " + str(increase_defense_allocator_data.unlock_level), increase_defense_allocator_data.unlock_level <= in_current_boss_level)
	increase_defense_speed_allocator.set_unlocked("Unlocked at Boss Level " + str(increase_defense_speed_allocator_data.unlock_level), increase_defense_speed_allocator_data.unlock_level <= in_current_boss_level)
	basic_hp_allocator.set_unlocked("Unlocked at Boss Level " + str(basic_hp_allocator_data.unlock_level), basic_hp_allocator_data.unlock_level <= in_current_boss_level)
