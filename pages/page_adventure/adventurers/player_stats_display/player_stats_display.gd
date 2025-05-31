extends Node

@onready var _coins_label: RichTextLabel = %"CoinsLabel"
@onready var _income_label: RichTextLabel = %"IncomeLabel"
@onready var _xp_label: RichTextLabel = %"XpLabel"

func _ready() -> void:
	AdventureResources.on_coins_amount_changed.connect(_update_coins_text)
	AdventureResources.on_income_amount_changed.connect(_update_income_text)
	AdventureResources.on_xp_amount_changed.connect(_update_xp_text)
	_update_coins_text(AdventureResources.coins)
	_update_income_text(AdventureResources.income)
	_update_xp_text(AdventureResources.xp)

func _update_coins_text(in_amount: int) -> void:
	_coins_label.text = "[b]" + str(in_amount) + "[/b] [color=gold][b]Coins[/b][/color]"

func _update_income_text(in_amount: int) -> void:
	_income_label.text = "+" + str(in_amount) + " [color=gold][b]Coins[/b][/color] / [b]Day[/b]"

func _update_xp_text(in_amount: int) -> void:
	_xp_label.text = "[b]" + str(in_amount) + "[/b] / 10 [color=plum][b]XP[/b]"
