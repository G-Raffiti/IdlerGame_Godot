extends PageBase
class_name PageAdventure

@export_group("Intro")
@export var skill_choices: Array[SkillData] = [null, null, null]
var skill_selected: SkillData

@export_group("Combat")
@export var player: Adventurer
@export var fights: Array[Adventurer]

@export_group("Dependencies")
@export_group("Dependencies/Intro")
@export var intro: Control
@export var skill_choice_1_btn: Button
@export var skill_choice_2_btn: Button
@export var skill_choice_3_btn: Button
@export var start: Button
@export_group("Dependencies/Combat")
@export var combat: Combat
@export var chest_button: Button
@export var player_board: Control
@export var player_chest: Control
@export var monster_board: Control



func _ready() -> void:
	# Intro
	start.pressed.connect(_start_adventure)
	skill_choice_1_btn.pressed.connect(func() -> void: select(1))
	skill_choice_2_btn.pressed.connect(func() -> void: select(2))
	skill_choice_3_btn.pressed.connect(func() -> void: select(3))
	select(0)


	# Combat
	chest_button.toggled.connect(_toggle_chest_view)

	intro.visible = true
	combat.visible = false


func select(in_index: int) -> void:
	skill_choice_1_btn.get_node("Select").visible = in_index == 1
	skill_choice_2_btn.get_node("Select").visible = in_index == 2
	skill_choice_3_btn.get_node("Select").visible = in_index == 3
	if in_index == 0 or in_index >= skill_choices.size(): return
	skill_selected = skill_choices[in_index - 1]

func _start_adventure() -> void:
	if skill_selected == null: return
	
	intro.visible = false
	combat.visible = true

func _toggle_chest_view(in_state: bool) -> void:
	player_chest.visible = in_state
	monster_board.visible = !in_state
