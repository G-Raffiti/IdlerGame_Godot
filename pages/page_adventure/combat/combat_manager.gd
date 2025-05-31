extends Node
class_name Combat

enum Trigger { ON_NEIGHBOURS_ACTIVATE, }

signal on_combat_ends(in_is_victory: bool)

@onready var page_adventure: Adventure = get_parent()

@export var player_hp_bar: AdventurerBar
@export var enemy_hp_bar: AdventurerBar
@export var sand_storm_bar: ProgressBar

var player_board: Dictionary[int, SkillObject]
var enemy_board: Dictionary[int, SkillObject]
var player: Adventurer
var enemy: Adventurer
var sand_storm_damage: int = 1
var sand_storm_cooldown: float = 30
var sand_storm_timer: Timer = null
var poison_timer: Timer = null
var regen_timer: Timer = null
var burn_timer: Timer = null

func start_combat(in_enemy: Adventurer) -> void:
	lock_combat_mode(true)
	clear_combat_signals()
	player = AdventureResources.adventurer.duplicate()
	player.hp = player.max_hp
	player.hp_changed.connect(check_loose)
	enemy = in_enemy
	enemy.hp = enemy.max_hp
	enemy.hp_changed.connect(check_win)
	player_hp_bar.register_adventurer(player)
	enemy_hp_bar.register_adventurer(enemy)
	init_dot_timers()
	initialize_combat()
	_init_sand_storm()

	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame

	for index: int in player_board:
		player_board[index].start()
	for index: int in enemy_board:
		enemy_board[index].start()

func stop_combat() -> void:
	sand_storm_timer.stop()
	poison_timer.stop()
	regen_timer.stop()
	burn_timer.stop()
	for index: int in player_board:
		player_board[index].stop()
	for index: int in enemy_board:
		enemy_board[index].stop()
	clear_combat_signals()

func exit_combat() -> void:
	for child: Node in page_adventure.player_board.slots.get_children():
		var slot: SkillSlot = child as SkillSlot
		if slot.get_child_count() <= 0: continue
		(slot.get_child(0) as SkillObject).end_combat()
	lock_combat_mode(false)
	player = AdventureResources.adventurer.duplicate()
	player.hp = player.max_hp
	player_hp_bar.register_adventurer(player)
	enemy_hp_bar.register_adventurer(null)

func clear_combat_signals() -> void:
	if sand_storm_timer:
		SignalBus.clear_signal(sand_storm_timer.timeout)
	if poison_timer:
		SignalBus.clear_signal(poison_timer.timeout)
	if regen_timer:
		SignalBus.clear_signal(regen_timer.timeout)
	if burn_timer:
		SignalBus.clear_signal(burn_timer.timeout)
	if player != null:
		player.hp_changed.disconnect(check_loose)
	if enemy != null:
		enemy.hp_changed.disconnect(check_win)
	for index: int in player_board:
		SignalBus.clear_signal(player_board[index].on_activate)
	for index: int in enemy_board:
		SignalBus.clear_signal(enemy_board[index].on_activate)

func initialize_combat() -> void:
	for child: Node in page_adventure.player_board.slots.get_children():
		var slot: SkillSlot = child as SkillSlot
		if slot == null or slot.is_empty(): continue
		if slot.get_child_count() <= 0: continue
		player_board[slot.index] = slot.get_child(0) as SkillObject
		player_board[slot.index].on_activate.connect(_on_player_item_activate)
		call_deferred("_register_trigger", player_board[slot.index], slot.index, player, player_board, enemy, enemy_board)
	for child: Node in page_adventure.monster_board.slots.get_children():
		var slot: SkillSlot = child as SkillSlot
		if slot == null or slot.is_empty(): continue
		if slot.get_child_count() <= 0: continue
		enemy_board[slot.index] = slot.get_child(0) as SkillObject
		enemy_board[slot.index].start()
		enemy_board[slot.index].on_activate.connect(_on_enemy_item_activate)
		call_deferred("_register_trigger", enemy_board[slot.index], slot.index, enemy, enemy_board, player, player_board)

func lock_combat_mode(in_state: bool) -> void:
	page_adventure.player_board.drag_disabled = in_state
	page_adventure.player_board.drop_disabled = in_state
	page_adventure.chest_button.disabled = in_state
	if in_state:
		page_adventure.player_chest.visible = !in_state
		page_adventure.monster_board.visible = in_state

func _on_player_item_activate(in_index: int, in_item: SkillObject) -> void:
	for skill_effect: Skill_Effect in in_item.data.active_effects:
		skill_effect.activate(in_item.current, in_index, player, player_board, enemy, enemy_board)

func _on_enemy_item_activate(in_index: int, in_item: SkillObject) -> void:
	for skill_effect: Skill_Effect in in_item.data.active_effects:
		skill_effect.activate(in_item.current, in_index, enemy, enemy_board, player, player_board)

static func _register_trigger(in_skill_object: SkillObject, in_index: int, in_player: Adventurer, in_player_board: Dictionary[int, SkillObject], in_enemy: Adventurer, in_enemy_board: Dictionary[int, SkillObject]) -> void:
	for trigger: Trigger in in_skill_object.data.triggered_effects:
		match trigger:
			Trigger.ON_NEIGHBOURS_ACTIVATE:
				if in_player_board.has(in_index - 1):
					in_player_board[in_index - 1].on_activate.connect(
					func(_index: int, _data: SkillData) -> void:\
						for skill_effect: Skill_Effect in in_skill_object.data.triggered_effects[trigger].list:
							skill_effect.activate(in_skill_object.current, in_index, in_player, in_player_board, in_enemy, in_enemy_board))
				if in_player_board.has(in_index + in_skill_object.data.size):
					in_player_board[in_index + in_skill_object.data.size].on_activate.connect(
					func(_index: int, _data: SkillData) -> void: 
						for skill_effect: Skill_Effect in in_skill_object.data.triggered_effects[trigger].list: 
							skill_effect.activate(in_skill_object.current, in_index, in_player, in_player_board, in_enemy, in_enemy_board))

func _init_sand_storm() -> void:
	if sand_storm_timer == null:
		sand_storm_timer = Timer.new()
		add_child(sand_storm_timer)
	sand_storm_timer.wait_time = sand_storm_cooldown
	sand_storm_timer.timeout.connect(_preview_sand_storm, CONNECT_ONE_SHOT)
	sand_storm_timer.one_shot = true
	sand_storm_bar.visible = false
	sand_storm_timer.start()

func _preview_sand_storm() -> void:
	sand_storm_bar.value = 0
	sand_storm_bar.max_value = 5.0
	sand_storm_bar.visible = true
	var t: Tween = get_tree().create_tween()
	t.tween_property(sand_storm_bar, "value", 5.0, 5.0)
	sand_storm_timer.timeout.connect(_begin_sand_storm, CONNECT_ONE_SHOT)
	sand_storm_timer.start(5.0)

func _begin_sand_storm() -> void:
	sand_storm_timer.one_shot = false
	sand_storm_timer.timeout.connect(_sand_storm_tick)
	sand_storm_timer.start(0.5)

func _sand_storm_tick() -> void:
	player.take_damage(sand_storm_damage)
	enemy.take_damage(sand_storm_damage)
	sand_storm_damage += 1

func init_dot_timers() -> void:
	if poison_timer == null:
		poison_timer = Timer.new()
		add_child(poison_timer)
	poison_timer.one_shot = false
	poison_timer.timeout.connect(player.take_poison_damage)
	poison_timer.timeout.connect(enemy.take_poison_damage)
	poison_timer.start(2.0)

	if burn_timer == null:
		burn_timer = Timer.new()
		add_child(burn_timer)
	burn_timer.one_shot = false
	burn_timer.timeout.connect(player.take_burn_damage)
	burn_timer.timeout.connect(enemy.take_burn_damage)
	burn_timer.start(1.0)
	
	if regen_timer == null:
		regen_timer = Timer.new()
		add_child(regen_timer)
	regen_timer.one_shot = false
	regen_timer.timeout.connect(player.take_regen)
	regen_timer.timeout.connect(enemy.take_regen)
	regen_timer.start(1.5)

func check_loose(_amount: int) -> void:
	if player.hp > 0: return
	stop_combat()
	on_combat_ends.emit(false)

func check_win(_amount: int) -> void:
	if enemy.hp > 0: return
	stop_combat()
	on_combat_ends.emit(true)
