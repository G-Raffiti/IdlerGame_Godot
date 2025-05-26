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
        for hour_index: int in range(0, 7):
            var hours: Array[Adventure_EventData] = day.get("hour_" + str(hour_index)).duplicate()
            var selected_hours: Array[Adventure_EventData] = []
            if hours.is_empty():
                printerr("Could not create complete Run: day ", str(day_index), " hour ", str(hour_index), " is empty")
                return run_data
            for i: int in 3:
                selected_hours.append(hours.pick_random())
                hours.remove_at(hours.find(selected_hours[i]))
                if hours.is_empty():
                    break
            run_data[day_index].append(selected_hours)
    return run_data