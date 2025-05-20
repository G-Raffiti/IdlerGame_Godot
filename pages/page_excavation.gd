extends PageBase
class_name PageExcavation

signal on_gold_button_clicked(in_amount: Dictionary[E.Res, Vector2])

@export_category("Button")
@export var excavation_button: ResourceButton
@export var base_amount_per_click: Dictionary[E.Res, Vector2] = { E.Res.GOLD: Vector2(1.0, 0) }
var multiplier: Dictionary[E.Res, Vector2] = { E.Res.GOLD: Vector2(1.0, 0), E.Res.ENERGY: Vector2(1.0, 0) }
var total_per_click: Dictionary[E.Res, Vector2] = { E.Res.GOLD: Vector2(1.0, 0) }

@export_category("Upgrades")
@export_group("Auto Click")
@export var auto_click: ResourceAllocator
@export var auto_click_data: ResourceAllocator_Data

@export_group("Auto Click Max Gold")
@export var auto_click_max_gold: ResourceAllocator
@export var auto_click_max_gold_data: ResourceAllocator_Data

@export_group("Improve Click +")
@export var improve_click_add: ResourceAllocator
@export var improve_click_add_data: ResourceAllocator_Data
@export var improve_click_add_value: Dictionary[E.Res, Vector2]

@export_group("Improve Click x")
@export var improve_click_mult: ResourceAllocator
@export var improve_click_mult_data: ResourceAllocator_Data
@export var improve_click_mult_value: Dictionary[E.Res, Vector2]

func register_to_manager(in_manager: Manager) -> void:
	super.register_to_manager(in_manager)
	in_manager.excavation = self
	initialize_excavation()

func initialize_excavation() -> void:
	excavation_button.pressed.connect(gain_button_resources)
	
	auto_click.init_data(auto_click_data)
	auto_click.on_change_amount_pressed.connect(manager.add_energy_to_allocator)
	auto_click.on_bar_filled.connect(on_auto_click)
	
	auto_click_max_gold.init_data(auto_click_max_gold_data)
	auto_click_max_gold.on_change_amount_pressed.connect(manager.add_energy_to_allocator)
	auto_click_max_gold.on_bar_filled.connect(manager.increase_max_gold)
	
	improve_click_add.init_data(improve_click_add_data)
	improve_click_add.on_change_amount_pressed.connect(manager.add_energy_to_allocator)
	improve_click_add.on_bar_filled.connect(bonus_add_amount_per_click)
	
	improve_click_mult.init_data(improve_click_mult_data)
	improve_click_mult.on_change_amount_pressed.connect(manager.add_energy_to_allocator)
	improve_click_mult.on_bar_filled.connect(bonus_mult_amount_per_click)
	
	manager.on_reset_energy_allocation.connect(excavation_reset_energy_allocation)


func excavation_reset_energy_allocation() -> void:
	auto_click.allocate_resource(Number.minus(auto_click.current_allocated))
	auto_click_max_gold.allocate_resource(Number.minus(auto_click_max_gold.current_allocated))
	improve_click_add.allocate_resource(Number.minus(improve_click_add.current_allocated))
	improve_click_mult.allocate_resource(Number.minus(improve_click_mult.current_allocated))


func gain_button_resources() -> void:
	var amount_gained: Dictionary[E.Res, Vector2] = total_per_click
	RS.add_resources(amount_gained)


func on_auto_click() -> void:
	auto_click.maximum_allocated = Number.add(auto_click.maximum_allocated, Vector2(1.0, -1))
	excavation_button.click()


func bonus_add_amount_per_click() -> void:
	for type: E.Res in improve_click_add_value:
		base_amount_per_click[type] = Number.add(base_amount_per_click[type], improve_click_add_value[type])
		total_per_click[type] = Number.mult(base_amount_per_click[type], multiplier[type])


func bonus_mult_amount_per_click() -> void:
	for type: E.Res in improve_click_mult_value:
		multiplier[type] = Number.mult(multiplier[type], improve_click_mult_value[type])
		total_per_click[type] = Number.mult(base_amount_per_click[type], multiplier[type])

func _on_current_boss_level_changed(in_current_boss_level) -> void:
	auto_click.set_unlocked("Unlocked at Boss Level 4", in_current_boss_level >= 4)
	auto_click_max_gold.set_unlocked("Unlocked at Boss Level 4", in_current_boss_level >= 4)
