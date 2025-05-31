extends Node

signal on_coins_amount_changed(in_amount: int)
signal on_income_amount_changed(in_amount: int)
signal on_xp_amount_changed(in_amount: int)

var coins: int = 14:
    get: return coins
    set(value):
        coins = value
        on_coins_amount_changed.emit(value)
var income: int = 5:
    get: return income
    set(value):
        income = value
        on_income_amount_changed.emit(value)
var influence: int = 20
var level: int = 1
var xp: int = 1:
    get: return xp
    set(value):
        xp = value
        on_xp_amount_changed.emit(value)

var adventurer: Adventurer

var day: int = 0
var hour: int = 0

var character: SkillData.Collection
