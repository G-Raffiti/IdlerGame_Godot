extends Resource
class_name Adventure_HourData

@export var forced_event_pool: Array[Adventure_EventData] = []
@export var other_event_pool: Array[Adventure_EventData] = []
@export var number_of_event: int
@export var number_of_forced_event: int

func get_events(in_character_played: SkillData.Collection) -> Array[Adventure_EventData]:
    var events: Array[Adventure_EventData] = []
    var pool: Array[Adventure_EventData] = forced_event_pool.duplicate()
    for i: int in number_of_forced_event:
        if pool.is_empty(): break
        var event: Adventure_EventData = pool.pick_random()
        pool.remove_at(pool.find(event))
        if event.character_played.has(in_character_played):
            events.append(event)
    pool = other_event_pool.duplicate()
    for i: int in range(events.size(), number_of_event, 1):
        if pool.is_empty(): break
        var event: Adventure_EventData = pool.pick_random()
        pool.remove_at(pool.find(event))
        if event.character_played.has(in_character_played):
            events.append(event)
    return events

