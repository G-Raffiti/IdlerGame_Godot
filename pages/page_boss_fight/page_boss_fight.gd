extends PageBase
class_name PageBossFight

signal on_fight_loss()
const creature_ps: PackedScene = preload("uid://ci1ut4cmxwup2")

@export var player_creature: Creature
var creature: Creature
@export var fight_button: Button
@export var flee_button: Button
@export var refresh_button: Button
@onready var text_area: RichTextLabel = %BossFightTextArea
@export var enemies_container: HBoxContainer
@export var boss_fights: Array[Creature_Data]
var is_in_fight: bool


func register_to_manager(in_manager: Manager) -> void:
	manager = in_manager
	manager.boss_fight = self
	initialize()


func open_page() -> void:
	clear_creature()
	_update_player_stats()
	if RS.current_boss_level >= boss_fights.size():
		var label = RichTextLabel.new()
		label.text = "Victory"
		enemies_container.add_child(label)
		return
	_initialize_enemies()


func close_page() -> void:
	if is_in_fight:
		_stop_fight()


func _update_player_stats() -> void:
	if is_in_fight: return
	var player_data: Creature_Data = Creature_Data.new()
	player_data.hp = RS.hp.maximum_amount
	player_data.attack = RS.attack.amount
	player_data.attack_duration = RS.attack_duration.get_total_with_bonus()
	player_data.defense = RS.defense.amount
	player_data.defense_duration = RS.defense_duration.get_total_with_bonus()
	player_data.regen = RS.regen.amount
	player_creature.initialize_creature(player_data)
	player_creature.hp = RS.hp.amount


func clear_creature() -> void:
	for i: int in enemies_container.get_child_count():
		var child = enemies_container.get_child(0)
		if child == null:
			continue
		if child == creature:
			player_creature.on_attack_done.disconnect(creature.take_hit)
			creature.on_attack_done.disconnect(player_creature.take_hit)
			creature.on_dead.disconnect(_win_fight)
			creature == null
		enemies_container.remove_child(child)
		child.queue_free()


func _initialize_enemies() -> void:
	var enemy_data: Creature_Data = boss_fights[RS.current_boss_level]
	creature = creature_ps.instantiate()
	enemies_container.add_child(creature)
	creature.initialize_creature(enemy_data)
	player_creature.on_attack_done.connect(creature.take_hit)
	creature.on_attack_done.connect(player_creature.take_hit)
	creature.on_dead.connect(_win_fight)
	text_area.text = enemy_data.text + "\n" + \
		Utils.resources_to_str(enemy_data.resources_gained_on_killed)


func initialize() -> void:
	fight_button.pressed.connect(_start_fight)
	player_creature.on_dead.connect(_lose_fight)
	flee_button.pressed.connect(_stop_fight)
	refresh_button.pressed.connect(_update_player_stats)


func _start_fight() -> void:
	_update_player_stats()
	is_in_fight = true
	player_creature.start()
	creature.start()


func _stop_fight() -> void:
	RS.hp.amount = player_creature.hp
	player_creature.stop()
	if creature != null:
		creature.stop()
	is_in_fight = false


func _win_fight() -> void:
	RS.add_resources(boss_fights[RS.current_boss_level].resources_gained_on_killed)
	RS.current_boss_level += 1
	text_area.text = "[b]Victory ![/b]\nYou killed the last boss of the DEMO"
	_stop_fight()
	open_page()


func _lose_fight() -> void:
	_stop_fight()
	open_page()
	manager.reset_energy_allocation()
	RS.energy.amount = Vector2(0.0, 0)


func get_boss_stats() -> Creature_Data:
	if RS.current_boss_level >= boss_fights.size():
		return null
	return boss_fights[RS.current_boss_level]
