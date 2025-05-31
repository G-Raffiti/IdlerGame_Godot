extends Resource
class_name Adventurer

enum CombatResource { COINS, XP, INCOME }

@export var max_hp: int
var hp: int
var shield: int
var poison: int
var burn: int
var regen: int

@export var level: int = 1
@export var reward: Dictionary[CombatResource, int] = {CombatResource.COINS: 4, CombatResource.XP: 2}

@export var board: Array[Adventurer_ItemTier] = []
@export var passifs: Array[Resource] = []

signal max_hp_changed(in_delta: int)
signal hp_changed(in_damage: int)
signal shield_changed(in_damage: int)
signal burn_damage(in_stack: int)
signal burn_stack_changed()
signal poison_damage(in_stack: int)
signal poison_stack_changed()
signal regen_stack_changed()

signal over_heal()


func modify_max_hp(in_amount: int) -> void:
    max_hp = max(1, in_amount)
    max_hp_changed.emit(in_amount)

func heal(in_amount: int) -> void:
    if hp + in_amount > max_hp:
        over_heal.emit()
    hp = clamp(hp + in_amount, 0, max_hp)
    hp_changed.emit(in_amount)
    apply_poison(-1)

func apply_shield(in_amount: int) -> void:
    shield = max(shield + in_amount, 0)
    shield_changed.emit(in_amount)

func take_damage(in_amount: int) -> void:
    if in_amount < 0:
        heal(in_amount)
        return
    var shield_damage: int = min(shield, in_amount)
    if shield_damage > 0:
        shield -= shield_damage
        shield_changed.emit(-shield_damage)
    if shield > 0: return
    var damage: int = max(0, in_amount - shield_damage)
    hp -= damage
    hp_changed.emit(-damage)

func apply_poison(in_amount: int) -> void:
    poison = max(0, poison + in_amount)
    poison_stack_changed.emit()

func take_poison_damage() -> void:
    if poison <= 0: return
    hp -= poison
    poison_damage.emit(poison)

func apply_burn(in_amount: int) -> void:
    burn = max(0, burn + in_amount)
    burn_stack_changed.emit()

func take_burn_damage() -> void:
    if burn <= 0: return
    var shield_damage: int = min(shield, burn / 2)
    shield -= shield_damage
    burn_damage.emit(-shield_damage)
    if shield > 0: 
        apply_burn(-1)
        return
    var damage: int = max(0, burn - shield_damage)
    hp -= damage
    burn_damage.emit(-damage)
    apply_burn(-1)

func take_regen() -> void:
    if hp == max_hp: return
    if regen <= 0: return
    heal(regen)

func apply_regen(in_amount: int) -> void:
    regen = max(0, regen + in_amount)
    apply_poison(-1)
    regen_stack_changed.emit()