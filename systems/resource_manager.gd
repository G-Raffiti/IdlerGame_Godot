extends Node
class_name ResourceManager

signal on_amount_changed()
signal on_maximum_amount_changed()
signal on_amount_used_changed()
signal on_production_changed()
signal on_global_value_changed()


var amount: Vector2 = Vector2.ZERO:
	get(): return amount
	set(value): 
		amount = value
		on_amount_changed.emit()
	
var amount_used: Vector2 = Vector2.ZERO:
	set(value): 
		amount_used = value
		on_amount_used_changed.emit()

var maximum_amount: Vector2 = Vector2(1.0, 4):
	get(): return maximum_amount
	set(value):
		maximum_amount = value
		on_maximum_amount_changed.emit()

var _base_tick_duration: Vector2 = Vector2(1.0, 0)
var _base_amount_per_tick: Vector2 = Vector2(1.0, 0)

var _last_bonus_id: int = 0
var _bonus_flat: Dictionary[int, Vector2] = {}
var _total_flat_bonus: Vector2 = Vector2(0, 0)
var _bonus_inc: Dictionary[int, Vector2] = {}
var _total_inc_bonus: Vector2 = Vector2(1.0, 0)
var _bonus_mult: Dictionary[int, Vector2] = {}
var _total_mult_bonus: Vector2 = Vector2(1.0, 0)
var _bonus_incresse_speed: Dictionary[int, Vector2] = {}
var _total_speed_bonus: Vector2 = Vector2(1.0, 0)
 
var _global_value_inc: Dictionary[int, Vector2] = {}
var total_global_value_inc: Vector2 = Vector2(1.0, 0)

var _timer: Timer
var _tick_duration: Vector2:
	set(value):
		_tick_duration = value
var _amount_per_tick: Vector2


func _ready() -> void:
	_recalculate()
	_timer = Timer.new()
	_timer.wait_time = Settings.income_frequency
	_timer.autostart = true
	_timer.one_shot = false
	add_child(_timer)
	_timer.timeout.connect(_gain_income)
	on_global_value_changed.emit()


func _gain_income() -> void:
	add(_amount_per_tick)


func _recalculate() -> void:
	var amount_per_tick: Vector2 = Number.add(_base_amount_per_tick, _total_flat_bonus)
	amount_per_tick = Number.mult(amount_per_tick, _total_inc_bonus)
	amount_per_tick = Number.mult(amount_per_tick, _total_mult_bonus)
	_amount_per_tick = Number.mult(amount_per_tick, Settings.income_frequency_number)
	_tick_duration = Number.mult(Number.div(_base_tick_duration, _total_speed_bonus), Settings.income_frequency_number)
	on_production_changed.emit()


func load(in_amount: Vector2, in_max_amount: Vector2, in_production_per_tick: Vector2, in_tick_duration: Vector2) -> void:
	amount = in_amount
	maximum_amount = in_max_amount
	_base_tick_duration = in_tick_duration
	_base_amount_per_tick = in_production_per_tick
	_recalculate()

func add(in_added_amount: Vector2) -> void:
	if Number.is_smaller(maximum_amount, Vector2.ZERO):
		amount = Number.max_num(Number.add(amount, Number.mult(in_added_amount, total_global_value_inc)), Vector2(0, 0))
	else:
		amount = Number.clamp(Number.add(amount, Number.mult(in_added_amount, total_global_value_inc)), Vector2(0, 0), maximum_amount)


func use(in_amount: Vector2) -> void:
	amount_used = Number.add(amount_used, in_amount)


func _regen_total_speed() -> void:
	_total_speed_bonus = Vector2(1.0, 0)
	for i: int in _bonus_incresse_speed:
		_total_speed_bonus = Number.mult(_total_speed_bonus, _bonus_incresse_speed[i])


func increase_speed(in_factor: Vector2) -> int:
	if in_factor.x == 0.0: return -1
	_last_bonus_id += 1
	_bonus_incresse_speed[_last_bonus_id] = in_factor
	_regen_total_speed()
	_recalculate()
	return _last_bonus_id

func _regen_total_flat() -> void:
	_total_flat_bonus = Vector2.ZERO
	for i: int in _bonus_flat:
		_total_flat_bonus = Number.add(_total_flat_bonus, _bonus_flat[i])

func add_flat_bonus(in_bonus: Vector2) -> int:
	if in_bonus.x == 0.0: return -1
	_last_bonus_id += 1
	_bonus_flat[_last_bonus_id] = in_bonus
	_regen_total_flat()
	_recalculate()
	return _last_bonus_id

func _regen_total_inc() -> void:
	_total_inc_bonus = Vector2(1.0, 0)
	for i: int in _bonus_inc:
		_total_inc_bonus = Number.add(_total_inc_bonus, _bonus_inc[i])

func add_inc_bonus(in_bonus: Vector2) -> int:
	if in_bonus.x == 0.0: return -1
	_last_bonus_id += 1
	_bonus_inc[_last_bonus_id] = in_bonus
	_regen_total_inc()
	_recalculate()
	return _last_bonus_id

func _regen_total_mult() -> void:
	_total_mult_bonus = Vector2(1.0, 0)
	for i: int in _bonus_mult:
		_total_mult_bonus = Number.mult(_total_mult_bonus, _bonus_mult[i])

func add_mult_bonus(in_bonus: Vector2) -> int:
	if in_bonus.x == 0.0: return -1
	_last_bonus_id += 1
	_bonus_mult[_last_bonus_id] = in_bonus
	_regen_total_mult()
	_recalculate()
	return _last_bonus_id


func get_production() -> Vector2:
	return Number.div(_amount_per_tick, _tick_duration)


func get_percent() -> float:
	return Number.to_float(Number.div(amount, maximum_amount))

func get_available() -> Vector2:
	return Number.sub(amount, amount_used)

func add_global_value_inc(in_global_inc: Vector2) -> int:
	if in_global_inc.x == 0.0: return -1
	_last_bonus_id += 1
	_global_value_inc[_last_bonus_id] = in_global_inc
	total_global_value_inc = Vector2(1.0, 0)
	for i: int in _global_value_inc:
		total_global_value_inc = Number.add(total_global_value_inc, _global_value_inc[i])
	on_global_value_changed.emit()
	return _last_bonus_id

func get_total_with_bonus() -> Vector2:
	var amount_with_bonus: Vector2 = Number.add(amount, _total_flat_bonus)
	amount_with_bonus = Number.mult(amount_with_bonus, _total_inc_bonus)
	amount_with_bonus = Number.mult(amount_with_bonus, _total_mult_bonus)
	return amount_with_bonus

func update_bonus(in_id: int, in_new_value: Vector2) -> bool:
	if _last_bonus_id < in_id:
		return false
	if _bonus_flat.has(in_id):
		_bonus_flat[in_id] = in_new_value
		_regen_total_flat()
		_recalculate()
		return true
	if _bonus_inc.has(in_id):
		_bonus_inc[in_id] = in_new_value
		_regen_total_inc()
		_recalculate()
		return true
	if _bonus_mult.has(in_id):
		_bonus_mult[in_id] = in_new_value
		_regen_total_mult()
		_recalculate()
		return true
	if _bonus_incresse_speed.has(in_id):
		_bonus_incresse_speed[in_id] = in_new_value
		_regen_total_speed()
		_recalculate()
		return true
	return false
