extends Resource
class_name Adventure_RunData

@export var day_0: Adventure_DayData
@export var day_1: Adventure_DayData
@export var day_2: Adventure_DayData
@export var day_3: Adventure_DayData
@export var day_4: Adventure_DayData
@export var day_5: Adventure_DayData
@export var day_6: Adventure_DayData
@export var day_7: Adventure_DayData
@export var day_8: Adventure_DayData
@export var day_9: Adventure_DayData
@export var day_10: Adventure_DayData
@export var day_11: Adventure_DayData
@export var day_12: Adventure_DayData
@export var day_13: Adventure_DayData
@export var day_14: Adventure_DayData
@export var day_15: Adventure_DayData
@export var day_16: Adventure_DayData

var run_data: Array[Array]

func get_run() -> Array[Array]:
	if not run_data.is_empty():
		return run_data
	seed(randi())
	for day_index: int in range(0, 16):
		run_data.append([])
		var day: Adventure_DayData = get("day_" + str(day_index))
		if day == null:
			printerr("Could not create complete Run: day ", str(day_index), " is not set")
			return run_data
		for hour_index: int in range(0, 7):
			var hour: Adventure_HourData = day.get("hour_" + str(hour_index))
			if hour == null:
				printerr("Could not create complete Run: day ", str(day_index), " hour ", str(hour_index), " is empty")
				return run_data
			run_data[day_index].append(hour.get_events(AdventureResources.character))
	return run_data
