extends Node
class_name Number

#region    --- Convert --- 

static func from_int(in_int: int) -> Vector2:
	return clean(Vector2(in_int, 0))


static func from_float(in_float: float) -> Vector2:
	return clean(Vector2(in_float, 0))


static func to_float(in_number: Vector2) -> float:
	return in_number.x * pow(10, in_number.y)


static func clean(in_number: Vector2) -> Vector2:
	if Number.is_zero(in_number):
		return Vector2.ZERO
	var number: Vector2 = Vector2(abs(in_number.x), in_number.y)
	while number.x >= 10:
		number.x /= 10.0
		number.y += 1
	while number.x < 1:
		number.x *= 10.0
		number.y -= 1
	number.x *= sign(in_number.x)
	return Vector2(number.x, roundi(number.y))


static func match_exponent(in_number: Vector2, exponent: int) -> Vector2:
	var number: Vector2 = Vector2(abs(in_number.x), in_number.y)
	while int(number.y) > exponent:
		number.x *= 10.0
		number.y -= 1
	while int(number.y) < exponent:
		number.x /= 10.0
		number.y += 1
	number.x *= sign(in_number.x)
	return Vector2(number.x, roundi(number.y))


#endregion --- Convert ---


#region    --- Math ---

static func add(a: Vector2, b: Vector2) -> Vector2:
	var higher_exp: int = int(max(a.y, b.y))
	var number: Vector2 = Number.match_exponent(a, higher_exp)
	var other: Vector2 = Number.match_exponent(b, higher_exp)
	number.x += other.x
	return Number.clean(number)


static func sub(a: Vector2, b: Vector2) -> Vector2:
	var higher_exp: int = int(max(a.y, b.y))
	var number: Vector2 = Number.match_exponent(a, higher_exp)
	var other: Vector2 = Number.match_exponent(b, higher_exp)
	number.x -= other.x
	return Number.clean(number)


static func mult(a: Vector2, b: Vector2) -> Vector2:
	return Number.clean(Vector2(a.x * b.x, a.y + b.y))


static func div(a: Vector2, b: Vector2) -> Vector2:
	if b.x == 0:
		return Vector2(0.0, 0)
	return Number.clean(Vector2(a.x / b.x, a.y - b.y))


static func mult_float(a: Vector2, b: float) -> Vector2:
	return Number.mult(a, Vector2(b, 0))


static func div_float(a: Vector2, b: float) -> Vector2:
	return Number.div(a, Vector2(b, 0))


static func minus(a: Vector2) -> Vector2:
	return Vector2(-a.x, a.y)

#endregion --- Math ---


#region    --- Compare ---

static func is_zero(in_number: Vector2) -> bool:
	return in_number.x == 0.0


static func max_num(a: Vector2, b: Vector2) -> Vector2:
	a = Number.clean(a)
	b = Number.clean(b)
	return a if Number.is_greater_or_equal(a, b) else b


static func min_num(a: Vector2, b: Vector2) -> Vector2:
	a = Number.clean(a)
	b = Number.clean(b)
	return a if Number.is_smaller_or_equal(a, b) else b


static func clamp(a: Vector2, in_min: Vector2, in_max: Vector2) -> Vector2:
	a = Number.clean(a)
	in_min = Number.clean(in_min)
	in_max = Number.clean(in_max)
	
	if Number.is_smaller(in_min, in_max):
		return min_num(max_num(a, in_min), in_max)
	return min_num(max_num(a, in_max), in_min)


static func is_greater(a: Vector2, b: Vector2) -> bool:

	if sign(a.x) == sign(b.x):
		a = Number.clean(a)
		b = Number.clean(b)
		return a.y > b.y or (a.y == b.y and a.x > b.x)
	return sign(a.x) > sign(b.x)


static func is_equal(a: Vector2, b: Vector2) -> bool:
	a = Number.clean(a)
	b = Number.clean(b)
	return a == b


static func is_greater_or_equal(a: Vector2, b: Vector2) -> bool:
	return Number.is_equal(a, b) or Number.is_greater(a, b)


static func is_smaller(a: Vector2, b: Vector2) -> bool:
	if sign(a.x) == sign(b.x):
		a = Number.clean(a)
		b = Number.clean(b)
		return a.y < b.y or (a.y == b.y and a.x < b.x)
	return sign(a.x) < sign(b.x)


static func is_smaller_or_equal(a: Vector2, b: Vector2) -> bool:
	return Number.is_equal(a, b) or Number.is_smaller(a, b)


#endregion --- Compare ---

#region    --- Print ---

static func to_str(in_number: Vector2) -> String:
	in_number = clean(in_number)
	if abs(in_number.y) <= 5:
		if in_number.y <= 1:
			return "%.2f" % Number.to_float(in_number)
		return "%.0f" % Number.to_float(in_number)
	return "%.3f x10e%.0f" % [in_number.x, in_number.y]

static func to_str_percent(in_number: Vector2) -> String:
	in_number.y += 2
	in_number = clean(in_number)
	if abs(in_number.y) <= 5:
		if in_number.y <= 1:
			return "%.2f %%" % Number.to_float(in_number)
		return "%.0f %%" % Number.to_float(in_number)
	return "%.3f x10e%.0f %%" % [in_number.x, in_number.y]

static func to_str_int(in_number: Vector2) -> String:
	in_number = clean(in_number)
	if abs(in_number.y) <= 5:
		if in_number.y < 0:
			return "0"
		return "%.0f" % Number.to_float(in_number)
	return "%.3f x10e%.0f" % [in_number.x, in_number.y]

static func to_str_time(in_number: Vector2) -> String:
	in_number = clean(in_number)
	var hours: Vector2
	var minutes: Vector2
	var seconds: Vector2 = in_number
	minutes = from_int(int(match_exponent(div(seconds, Vector2(6.0, 1)), 0).x))
	seconds = sub(seconds, mult(minutes, Vector2(6.0, 1)))
	hours = from_int(int(match_exponent(div(minutes, Vector2(6.0, 1)), 0).x))
	minutes = sub(minutes, mult(hours, Vector2(6.0, 1)))
	if not is_zero(hours):
		return to_str_int(hours) + "h " + to_str_int(minutes) + "m " + to_str_int(seconds) + "s"
	if not is_zero(minutes):
		return to_str_int(minutes) + "m " + to_str_int(seconds) + "s"
	return to_str(seconds) + "s"
