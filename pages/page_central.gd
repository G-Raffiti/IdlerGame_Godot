extends PageBase
class_name Central

const saveable: bool = true

#region    --- Central ---
@export_category("Energy Production")
@export_group("Energy Production +")
@export var energy_prod_add_button: Button
@export var energy_prod_add_cost: Dictionary[E.Res, Vector2]: 
	get: return energy_prod_add_cost
	set(value): 
		energy_prod_add_cost = value
		call_deferred("_update_energy_prod_add_text")
@export var energy_prod_add_cost_increase: float = 1.33:
	get: return energy_prod_add_cost_increase
	set(value): 
		energy_prod_add_cost_increase = value
		call_deferred("_update_energy_prod_add_text")
@export var energy_prod_add_value: Vector2:
	get: return energy_prod_add_value
	set(value): 
		energy_prod_add_value = value
		call_deferred("_update_energy_prod_add_text")

@export_group("Energy Production Speed +%")
@export var energy_prod_speed_button: Button
@export var energy_prod_speed_cost: Dictionary[E.Res, Vector2]:
	get: return energy_prod_speed_cost
	set(value): 
		energy_prod_speed_cost = value
		call_deferred("_update_energy_prod_speed_text")
@export var energy_prod_speed_cost_increase: float = 1.33:
	get: return energy_prod_speed_cost_increase
	set(value): 
		energy_prod_speed_cost_increase = value
		call_deferred("_update_energy_prod_speed_text")
@export var energy_prod_speed_value: Vector2:
	get: return energy_prod_speed_value
	set(value): 
		energy_prod_speed_value = value
		call_deferred("_update_energy_prod_speed_text")

@export_group("Energy Max")
@export var energy_prod_max_button: Button
@export var energy_prod_max_cost: Dictionary[E.Res, Vector2]:
	get: return energy_prod_max_cost
	set(value):
		energy_prod_max_cost = value
		call_deferred("_update_energy_prod_max_text")
@export var energy_prod_max_value: Vector2:
	get: return energy_prod_max_value
	set(value):
		energy_prod_max_value = value
		call_deferred("_update_energy_prod_max_text")
@export var energy_prod_max_value_increase: float = 1.33:
	get: return energy_prod_max_value_increase
	set(value):
		energy_prod_max_value_increase = value
		call_deferred("_update_energy_prod_max_text")

func register_to_manager(in_manager: Manager) -> void:
	super.register_to_manager(in_manager)
	in_manager.central = self
	initialize_central()

func initialize_central() -> void:
	energy_prod_add_button.pressed.connect(energy_prod_add_func)
	energy_prod_speed_button.pressed.connect(energy_prod_speed_func)
	energy_prod_max_button.pressed.connect(energy_prod_max_func)
	_update_energy_prod_add_text()
	_update_energy_prod_speed_text()
	_update_energy_prod_max_text()

func energy_prod_add_func() -> void:
	if not RS.try_spend(energy_prod_add_cost):
		return
	RS.energy.add_flat_bonus(energy_prod_add_value)
	for type: E.Res in energy_prod_add_cost:
		energy_prod_add_cost[type] = Number.mult_float(energy_prod_add_cost[type], energy_prod_add_cost_increase)
	energy_prod_add_value = Number.add(energy_prod_add_value, Vector2(5.0, -1))
	
func _update_energy_prod_add_text() -> void:
	if not is_inside_tree(): return
	energy_prod_add_button.text = "+ " + Number.to_str(energy_prod_add_value) + " Energy / Bar (" + Number.to_str(energy_prod_add_cost[E.Res.GOLD]) + " Gold)"

func _update_energy_prod_speed_text() -> void:
	if not is_inside_tree(): return
	energy_prod_speed_button.text = "+ " + Number.to_str_percent(Number.sub(energy_prod_speed_value, Vector2(1.0, 0))) + " Energy Production Speed (" + Number.to_str(energy_prod_speed_cost[E.Res.GOLD]) + " Gold)"
	
func _update_energy_prod_max_text() -> void:
	if not is_inside_tree(): return
	energy_prod_max_button.text = "+ " + Number.to_str_percent(Number.sub(energy_prod_max_value, Vector2(1.0, 0))) + " Maximum Energy (" + Number.to_str(energy_prod_max_cost[E.Res.GOLD]) + " Gold and "  + Number.to_str(energy_prod_max_cost[E.Res.ENERGY]) + " Energy)"

func energy_prod_speed_func() -> void:
	if not RS.try_spend(energy_prod_speed_cost):
		return
	RS.energy.increase_speed(energy_prod_speed_value)
	for type: E.Res in energy_prod_speed_cost:
		energy_prod_speed_cost[type] = Number.mult_float(energy_prod_speed_cost[type], energy_prod_speed_cost_increase)
	_update_energy_prod_speed_text()

func energy_prod_max_func() -> void:
	if not RS.try_spend(energy_prod_max_cost):
		return
	RS.energy.maximum_amount = Number.mult(RS.energy.maximum_amount, energy_prod_max_value)
	energy_prod_max_value = Number.mult_float(energy_prod_max_value, energy_prod_max_value_increase)
	energy_prod_max_cost[E.Res.ENERGY] = Number.mult_float(RS.energy.maximum_amount, 0.9)
	energy_prod_max_cost[E.Res.GOLD] = Number.mult_float(energy_prod_max_cost[E.Res.ENERGY], 2.0)
