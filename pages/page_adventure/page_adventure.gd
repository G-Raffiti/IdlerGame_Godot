extends PageBase
class_name Adventure

const TAB_INDEX_CHEST: int = 0
const TAB_INDEX_MONSTER_BOARD: int = 1
const TAB_INDEX_SHOP: int = 2
const TAB_INDEX_EVENT_CHOICE: int = 3
const TAB_INDEX_EVENT_BUTTON_CONTAINER: int = 4

@export var run_data: Adventure_RunData

@export_group("Intro")
@export var character_choices: Array[SkillData.Collection] = [SkillData.Collection.PYGMALIEN, SkillData.Collection.DOOLEY, SkillData.Collection.VANESSA]
var character_selected: SkillData.Collection = SkillData.Collection.NONE
@export var starting_stats: Dictionary[SkillData.Collection, Adventurer]

@export_group("Combat")

@export_group("Dependencies")
@export var event_button_ps: PackedScene
@export_group("Dependencies/Intro")
@export var intro: Control
@export var character_choice_1: ButtonImage
@export var character_choice_2: ButtonImage
@export var character_choice_3: ButtonImage
@export var character_choice_4: ButtonImage
@export var start: Button
@export_group("Dependencies/Combat")
@export var event_portrait: TextureRect
@export var player_portrait: TextureRect
@export var combat: Combat
@export var chest_button: Button
@export var interact_button: ButtonRich
@export var next_button: ButtonRich
@export var tabs: TabContainer
@export var player_board: Board
@export var player_chest: Board
@export var monster_board: Board
@export var shop_board: Board
@export var event_button_container: BoxContainer
@export var event_choice_container: BoxContainer

@onready var adventure_data: AdventureData = preload("uid://b7kbibmnhimhg")

func _ready() -> void:
	# Intro
	start.pressed.connect(_start_adventure)
	character_choice_1.pressed.connect(func() -> void: select(1))
	character_choice_2.pressed.connect(func() -> void: select(2))
	character_choice_3.pressed.connect(func() -> void: select(3))
	character_choice_4.pressed.connect(func() -> void: select(4))
	select(0)


	# Combat
	chest_button.toggled.connect(_toggle_chest_view)

	intro.visible = true
	combat.visible = false


func select(in_index: int) -> void:
	character_choice_1.get_node("Select").visible = in_index == 1
	character_choice_2.get_node("Select").visible = in_index == 2
	character_choice_3.get_node("Select").visible = in_index == 3
	character_choice_4.get_node("Select").visible = in_index == 4
	if in_index == 0 or in_index > character_choices.size(): return
	character_selected = character_choices[in_index - 1]
	AdventureResources.character = character_selected
	AdventureResources.adventurer = starting_stats[character_selected]
	AdventureResources.adventurer.hp = AdventureResources.adventurer.max_hp
	combat.player_hp_bar.register_adventurer(AdventureResources.adventurer)
	AdventureResources.xp = starting_stats[character_selected].reward[Adventurer.CombatResource.XP]
	AdventureResources.coins = starting_stats[character_selected].reward[Adventurer.CombatResource.COINS]
	AdventureResources.income = starting_stats[character_selected].reward[Adventurer.CombatResource.INCOME]


func _start_adventure() -> void:
	if character_selected == SkillData.Collection.NONE: return
	player_portrait.texture = adventure_data.player_portraits[character_selected]
	player_board.clear_board()
	player_chest.clear_board()
	AdventureResources.hour = -1
	AdventureResources.day = 0
	next_event()

	intro.visible = false
	combat.visible = true

func _end_adventure() -> void:
	intro.visible = true
	combat.visible = false

var last_index: int = 0
func _toggle_chest_view(in_state: bool) -> void:
	if in_state:
		last_index = tabs.current_tab
		tabs.current_tab = TAB_INDEX_CHEST
	else:
		tabs.current_tab = last_index


func next_event() -> void:
	event_portrait.texture = null
	# clear previous event
	monster_board.clear_board()
	shop_board.clear_board()
	for child: Node in event_button_container.get_children():
		child.queue_free()
	
	# find next event
	AdventureResources.hour += 1
	if AdventureResources.hour >= 8:
		AdventureResources.hour = 0
		AdventureResources.day += 1
	if run_data.get_run().size() <= AdventureResources.day or run_data.get_run()[AdventureResources.day].size() <= AdventureResources.hour:
		_end_adventure()
		return
	
	# display events in container
	var days_events: Array[Adventure_EventData] = run_data.get_run()[AdventureResources.day][AdventureResources.hour]
	days_events.shuffle()
	while days_events.size() > 3:
		days_events.pop_back()
	for child: Node in event_choice_container.get_children():
		child.queue_free()
	for event: Adventure_EventData in days_events:
		var event_button: ButtonImage = event_button_ps.instantiate()
		event.customise_event_button(event_button)
		event_button.pressed.connect(func() -> void: event.initialize(tabs, interact_button, next_button); event_portrait.texture = event.icon)
		event.inject_dependencies(self, combat)
		event_choice_container.add_child(event_button)
	tabs.current_tab = TAB_INDEX_EVENT_CHOICE

	AdventureResources.xp += 1

	
		
