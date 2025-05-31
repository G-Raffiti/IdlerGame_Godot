@tool
extends Resource
class_name SkillData

enum Type { NONE, 
	WEAPON, 
	TOOL,
	DAMAGE,
	FREEZEREFERENCE,
	HASTEREFERENCE,
	VEHICLE,
	TOY,
	AMMO,
	AQUATIC,
	BURNREFERENCE,
	CHARGE,
	FRIEND,
	POISONREFERENCE,
	PROPERTY,
	SHIELDREFERENCE,
	DAMAGEREFERENCE,
	TECH,
	ECONOMY,
	SHIELD,
	APPAREL,
	POISON,
	REGEN,
	HASTE,
	CRIT,
	RAY,
	SLOW,
	HEAL,
	VALUE,
	HEALREFERENCE,
	CORE,
	AMMOREFERENCE,
	BURN,
	COOLDOWN,
	INCOME,
	LOOT,
	NONWEAPON,
	PASSIVE,
	RELIC,
	HEALTH,
	FREEZE,
	FOOD,
	POTION,
	CRITREFERENCE,
	ECONOMYREFERENCE,
	REAGENT,
	JUNK,
	GOLD,
	SLOWREFERENCE,
	DINOSAUR,
	HEALTHREFERENCE,
	DRAGON,
	REGENREFERENCE,
	LIFESTEAL,
	EXPERIENCE,
	MAX_ENUM,
}
enum Tier {
	NONE = 0,
	BRONZE = 1, 
	SILVER = 2, 
	GOLD = 3, 
	DIAMOND = 4, 
	LEGENDARY = 5, 
	MAX_ENUM,
}
enum Collection { 
	NONE, 
	PYGMALIEN, 
	VANESSA,
	DOOLEY,
	MAK,
	JUNK,
	JULES,
	MONSTER,
	STELLE,
	TREAT,
	LOOT,
	MAX_ENUM,
}

signal on_value_changed()

@export_group("Display")
@export var name: String = ""

@export var icon: Texture2D = null:
	get: return icon
	set(value):
		icon = value
		on_value_changed.emit()

@export_multiline var description: String = ""

@export_group("Gameplay Stats")
@export var cooldown: Array[float] = []

@export var ammo: Array[int] = []

@export var cost: Array[int]

@export var active_effects: Array[Skill_Effect] = []

@export var triggered_effects: Dictionary[Combat.Trigger, EffectList] = {}

@export_group("Sorting Stats")
@export_range(1, 3) var size: int = 1:
	get: return size
	set(value):
		size = value
		on_value_changed.emit()

@export var starting_tier: Tier = Tier.BRONZE

@export var collection: Collection

@export var type: Array[Type] = []

@export var is_generated_item: bool = false

enum DevState { ALL, NOT_IMPLEMENTED, PARTIALY_IMPLEMENTED, NEED_TEST, FULLY_WORKING }
@export_group("Dev Only")
@export var dev_state: DevState = DevState.NOT_IMPLEMENTED

static func get_type_from_string(in_string: String, context: String = "") -> Type:
	match in_string:
		"Weapon": return Type.WEAPON
		"Tool": return Type.TOOL
		"Damage": return Type.DAMAGE
		"FreezeReference": return Type.FREEZEREFERENCE
		"HasteReference": return Type.HASTEREFERENCE
		"Vehicle": return Type.VEHICLE
		"Toy": return Type.TOY
		"Ammo": return Type.AMMO
		"Aquatic": return Type.AQUATIC
		"BurnReference": return Type.BURNREFERENCE
		"Charge": return Type.CHARGE
		"Friend": return Type.FRIEND
		"PoisonReference": return Type.POISONREFERENCE
		"Property": return Type.PROPERTY
		"ShieldReference": return Type.SHIELDREFERENCE
		"DamageReference": return Type.DAMAGEREFERENCE
		"Tech": return Type.TECH
		"Economy": return Type.ECONOMY
		"Shield": return Type.SHIELD
		"Apparel": return Type.APPAREL
		"Poison": return Type.POISON
		"Regen": return Type.REGEN
		"Haste": return Type.HASTE
		"Crit": return Type.CRIT
		"Ray": return Type.RAY
		"Slow": return Type.SLOW
		"Heal": return Type.HEAL
		"Value": return Type.VALUE
		"HealReference": return Type.HEALREFERENCE
		"Core": return Type.CORE
		"AmmoReference": return Type.AMMOREFERENCE
		"Cooldown": return Type.COOLDOWN
		"Income": return Type.INCOME
		"Loot": return Type.LOOT
		"NonWeapon": return Type.NONWEAPON
		"Passive": return Type.PASSIVE
		"Relic": return Type.RELIC
		"Health": return Type.HEALTH
		"Freeze": return Type.FREEZE
		"Food": return Type.FOOD
		"Burn": return Type.BURN
		"Potion": return Type.POTION
		"CritReference": return Type.CRITREFERENCE
		"EconomyReference": return Type.ECONOMYREFERENCE
		"Reagent": return Type.REAGENT
		"Junk": return Type.JUNK
		"Gold": return Type.GOLD
		"SlowReference": return Type.SLOWREFERENCE
		"Dinosaur": return Type.DINOSAUR
		"HealthReference": return Type.HEALTHREFERENCE
		"Dragon": return Type.DRAGON
		"RegenReference": return Type.REGENREFERENCE
		"Lifesteal": return Type.LIFESTEAL
		"Experience": return Type.EXPERIENCE

		_:
			print("MISSING Type: ", '"', in_string, '"', ": return Type.", in_string.to_upper(), "   ", context)
			return Type.NONE

static func get_collection_from_string(in_string: String, context: String = "") -> Collection:
	match in_string:
		"Pygmalien": return Collection.PYGMALIEN
		"Vanessa": return Collection.VANESSA
		"Dooley": return Collection.DOOLEY
		"Mak": return Collection.MAK
		"Junk": return Collection.JUNK
		"Monster": return Collection.MONSTER
		"Jules": return Collection.JULES
		"Monster, Junk": return Collection.MONSTER
		"Stelle": return Collection.STELLE
		"Junk, Monster": return Collection.JUNK
		"Junk, Monster, Treat": return Collection.TREAT
		"Treat": return Collection.TREAT
		"Monster, Treat": return Collection.MONSTER
		"Loot, Monster": return Collection.LOOT
		"Junk, Loot, Monster": return Collection.JUNK
		"Loot": return Collection.LOOT
		_:
			print("MISSING Collection: ", '"', in_string, '"', ": return Collection.", in_string.to_upper(), "   ", context)
			return Collection.NONE

static func get_tier_from_string(in_string: String, context: String = "") -> Tier:
	match in_string:
		"Bronze": return Tier.BRONZE
		"Silver": return Tier.SILVER
		"Gold": return Tier.GOLD
		"Diamond": return Tier.DIAMOND
		"Legendary": return Tier.LEGENDARY
		_:
			print("MISSING Tier: ", '"', in_string, '"', ": return Tier.", in_string.to_upper(), "   ", context)
			return Tier.BRONZE
