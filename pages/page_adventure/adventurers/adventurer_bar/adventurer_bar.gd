extends Control
class_name AdventurerBar

@onready var hp_bar: ProgressBar = %"HPBar"
@onready var shield_bar: ProgressBar = %"ShieldBar"
@onready var hp_label: RichTextLabel = %"HPLabel"
@onready var shield_label: RichTextLabel = %"ShieldLabel"
@onready var poison_label: RichTextLabel = %"PoisonLabel"
@onready var burn_label: RichTextLabel = %"BurnLabel"
@onready var regen_label: RichTextLabel = %"RegenLabel"
@onready var animated_number_container: Control = %"Container"
@onready var animated_number: RichTextLabel = %"AnimatedNumber"

var adventurer: Adventurer = null
var animated_numbers: Dictionary[RichTextLabel, bool] = { animated_number: true }

var random: RandomNumberGenerator = RandomNumberGenerator.new()
func display_message(in_message: String) -> void:
	var label_instance: RichTextLabel = null
	for number: RichTextLabel in animated_numbers:
		if animated_numbers[number] == true:
			label_instance = number
			break
	if label_instance == null:
		label_instance = animated_number.duplicate(true)
		animated_number_container.add_child(label_instance, true)
	animated_numbers[label_instance] = false
	label_instance.text = in_message
	(label_instance.get_child(0) as AnimationPlayer).play("animate_number_" + str(random.randi_range(0, 2)))
	(label_instance.get_child(0) as AnimationPlayer).animation_finished.connect(func(_anime_name: String) -> void: animated_numbers[label_instance] = true)

func register_adventurer(in_adventurer: Adventurer) -> void:
	if adventurer != null:
		clear_signals()
	adventurer = in_adventurer
	visible = adventurer != null
	if adventurer == null: return
	set_hp()
	set_shield()
	burn_stack_changed()
	poison_stack_changed()
	regen_stack_changed()
	adventurer.max_hp_changed.connect(modify_max_hp)
	adventurer.hp_changed.connect(hp_changed)
	adventurer.shield_changed.connect(shield_changed)
	adventurer.burn_damage.connect(burn_damage)
	adventurer.burn_stack_changed.connect(burn_stack_changed)
	adventurer.poison_damage.connect(poison_damage)
	adventurer.poison_stack_changed.connect(poison_stack_changed)
	adventurer.regen_stack_changed.connect(regen_stack_changed)

func clear_signals() -> void:
	adventurer.max_hp_changed.disconnect(modify_max_hp)
	adventurer.hp_changed.disconnect(hp_changed)
	adventurer.shield_changed.disconnect(shield_changed)
	adventurer.burn_damage.disconnect(burn_damage)
	adventurer.burn_stack_changed.disconnect(burn_stack_changed)
	adventurer.poison_damage.disconnect(poison_damage)
	adventurer.poison_stack_changed.disconnect(poison_stack_changed)

func set_hp() -> void:
	hp_bar.max_value = adventurer.max_hp
	shield_bar.max_value = adventurer.max_hp
	hp_bar.value = adventurer.hp
	hp_label.text = "[font_size=27][color=yellow_green][b]" + str(adventurer.hp) + "[/b][/color][/font_size] / [color=yellow_green]" + str(adventurer.max_hp) + "[/color]"

func set_shield() -> void:
	shield_bar.value = adventurer.shield
	if adventurer.shield <= 0:
		shield_label.text = ""
		shield_bar.self_modulate = Color(0, 0, 0, 0)
		return
	shield_bar.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	shield_label.text = "[font_size=27][color=goldenrod][b]" + str(adventurer.shield) + "[/b][/color][/font_size]"

func modify_max_hp(in_amount: int) -> void:
	set_hp()
	var blod_str: String = "[b]" if abs(in_amount) > 500 else ""
	var sign_str: String = "+" if in_amount > 0 else ""
	display_message(blod_str + "[color=yellow_green]" + sign_str + str(in_amount))

func hp_changed(in_amount: int) -> void:
	set_hp()
	var blod_str: String = "[b]" if abs(in_amount) > 500 else ""
	var sign_str: String = "+" if in_amount > 0 else ""
	var color_str: String = "[color=yellow_green]" if in_amount > 0 else "[color=tomato]"
	display_message(blod_str + color_str + sign_str + str(in_amount))

func shield_changed(in_amount: int) -> void:
	set_shield()
	var blod_str: String = "[b]" if abs(in_amount) > 500 else ""
	var sign_str: String = "+" if in_amount > 0 else ""
	display_message(blod_str + "[color=goldenrod]" + sign_str + str(in_amount))

func burn_damage(in_amount: int) -> void:
	set_shield()
	set_hp()
	var blod_str: String = "[b]" if abs(in_amount) > 500 else ""
	display_message(blod_str + "[color=orange_red]" + str(in_amount))

func poison_damage(in_amount: int) -> void:
	set_hp()
	var blod_str: String = "[b]" if abs(in_amount) > 500 else ""
	display_message(blod_str + "[color=dark_green]" + str(in_amount))

func burn_stack_changed() -> void:
	if adventurer.burn <= 0:
		burn_label.text = ""
		return
	burn_label.text = "[color=orange_red][b]-" + str(adventurer.burn) + "[/b]/s[/color]"

func poison_stack_changed() -> void:
	if adventurer.poison <= 0:
		poison_label.text = ""
		return
	poison_label.text = "[color=dark_green][b]-" + str(adventurer.poison) + "[/b]/2s[/color]"

func regen_stack_changed() -> void:
	if adventurer.regen <= 0:
		regen_label.text = ""
		return
	regen_label.text = "[color=yellow_green][b]+" + str(adventurer.regen) + "[/b]/s[/color]"
