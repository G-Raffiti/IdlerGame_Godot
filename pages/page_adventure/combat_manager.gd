extends Node
class_name Combat

enum Trigger { ON_NEIGHBOURS_ACTIVATE, }

@onready var page_adventure: PageAdventure = get_parent()

var player_board: Dictionary[int, SkillObject]
var enemy_board: Dictionary[int, SkillObject]
var player: Adventurer
var enemy: Adventurer

func start_combat() -> void:
    lock_combat_mode(true)
    clear_combat_signals()
    initialize_combat()

    await get_tree().process_frame
    await get_tree().process_frame
    await get_tree().process_frame

    for index: int in player_board:
        player_board[index].start()
    for index: int in enemy_board:
        enemy_board[index].start()


func clear_combat_signals() -> void:
    for index: int in player_board:
        SignalBus.clear_signal(player_board[index].on_activate)
    for index: int in enemy_board:
        SignalBus.clear_signal(enemy_board[index].on_activate)


func initialize_combat() -> void:
    for child: Node in page_adventure.player_board.get_children():
        var slot: SkillSlot = child as SkillSlot
        if slot == null or slot.is_empty(): continue
        if slot.get_child_count() <= 0: continue
        player_board[slot.index] = slot.get_child(0) as SkillObject
        player_board[slot.index].on_activate.connect(_on_player_item_activate)
        call_deferred("_register_trigger", player_board[slot.index], slot.index, player, player_board, enemy, enemy_board)
    for child: Node in page_adventure.monster_board.get_children():
        var slot: SkillSlot = child as SkillSlot
        if slot == null or slot.is_empty(): continue
        if slot.get_child_count() <= 0: continue
        enemy_board[slot.index] = slot.get_child(0) as SkillObject
        enemy_board[slot.index].start()
        enemy_board[slot.index].on_activate.connect(_on_enemy_item_activate)
        call_deferred("_register_trigger", enemy_board[slot.index], slot.index, enemy, enemy_board, player, player_board)


func lock_combat_mode(in_state: bool) -> void:
    for child: Node in page_adventure.player_board.get_children():
        if child is SkillSlot:
            (child as SkillSlot).drag_and_drop_disabled = in_state
    page_adventure.chest_button.disabled = in_state
    if in_state:
        page_adventure.player_chest.visible = !in_state
        page_adventure.monster_board.visible = in_state


func _on_player_item_activate(in_index: int, in_data: SkillData) -> void:
    for skill_effect: Skill_Effect in in_data.active_effects:
        skill_effect.activate(in_data, in_index, player, player_board, enemy, enemy_board)


func _on_enemy_item_activate(in_index: int, in_data: SkillData) -> void:
    for skill_effect: Skill_Effect in in_data.active_effects:
        skill_effect.activate(in_data, in_index, enemy, enemy_board, player, player_board)


static func _register_trigger(in_skill_object: SkillObject, in_index: int, in_player: Adventurer, in_player_board: Dictionary[int, SkillObject], in_enemy: Adventurer, in_enemy_board: Dictionary[int, SkillObject]) -> void:
    for trigger: Trigger in in_skill_object.data.triggered_effects:
        match trigger:
            Trigger.ON_NEIGHBOURS_ACTIVATE:
                if in_player_board.has(in_index - 1):
                    in_player_board[in_index - 1].on_activate.connect(
                    func(_index: int, _data: SkillData) -> void:\
                        for skill_effect: Skill_Effect in in_skill_object.data.triggered_effects[trigger].list:
                            skill_effect.activate(in_skill_object.data, in_index, in_player, in_player_board, in_enemy, in_enemy_board))
                if in_player_board.has(in_index + in_skill_object.data.size):
                    in_player_board[in_index + in_skill_object.data.size].on_activate.connect(
                    func(_index: int, _data: SkillData) -> void: 
                        for skill_effect: Skill_Effect in in_skill_object.data.triggered_effects[trigger].list: 
                            skill_effect.activate(in_skill_object.data, in_index, in_player, in_player_board, in_enemy, in_enemy_board))
