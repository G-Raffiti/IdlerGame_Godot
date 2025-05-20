extends PageBase

@onready var energy_btn: Button = $CenterContainer/VBoxContainer/Button
@onready var max_energy_btn: Button = $CenterContainer/VBoxContainer/Button3
@onready var gold_btn: Button = $CenterContainer/VBoxContainer/Button2
@onready var max_gold_btn: Button = $CenterContainer/VBoxContainer/Button4

func _ready() -> void:
	energy_btn.pressed.connect(on_energy_btn_pressed)
	max_energy_btn.pressed.connect(on_max_energy_btn_pressed)
	gold_btn.pressed.connect(on_gold_btn_pressed)
	max_gold_btn.pressed.connect(on_max_gold_btn_pressed)

func on_energy_btn_pressed() -> void:
	RS.energy.add(RS.energy.maximum_amount)

func on_max_energy_btn_pressed() -> void:
	RS.energy.maximum_amount = Number.mult_float(RS.energy.maximum_amount, 2.0)

func on_gold_btn_pressed() -> void:
	RS.gold.add(RS.gold.maximum_amount)

func on_max_gold_btn_pressed() -> void:
	RS.gold.maximum_amount = Number.mult_float(RS.gold.maximum_amount, 2.0)
