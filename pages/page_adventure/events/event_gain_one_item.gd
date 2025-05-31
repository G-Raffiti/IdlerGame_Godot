extends Adventure_EventData
class_name Adventure_EventData_GainOneItem

@export_group("Items")
var adventure_data: AdventureData:
	get: 
		if adventure_data == null:
			adventure_data = preload("uid://b7kbibmnhimhg")
		return adventure_data
@export var item_filter: ItemFilter
@export var use_character_collection_filter: bool
@export var force_avaible_and_ignore_filter: bool
@export var tier_upgrade: int = 0
@export var available_items: Array[ItemCurrentData]
@export var items_per_rerol: int = 3
@export var rerol_starting_cost: int = 1
@export var can_rerol: bool = false

var shop: Board

func initialize(in_tabs: TabContainer, in_interact_button: ButtonRich, in_leave_button: ButtonRich) -> void:
	_init_items()
	in_tabs.current_tab = Adventure.TAB_INDEX_SHOP
	shop = in_tabs.get_child(Adventure.TAB_INDEX_SHOP)
	SignalBus.clear_signal(in_interact_button.pressed)
	if can_rerol:
		in_interact_button.pressed.connect(_rerol_shop)
		in_interact_button.button_text = "Rerol \n(" + str(rerol_starting_cost) + "[color=gold]Coins[/b])"
	else:
		in_interact_button.button_text = ""
	in_interact_button.disabled = not can_rerol
	SignalBus.clear_signal(in_leave_button.pressed)
	in_leave_button.button_text = "Next Event"
	in_leave_button.pressed.connect(page_adventure.next_event)
	in_leave_button.disabled = false
	refil_shop()

func refil_shop() -> void:
	shop.drop_disabled = false
	for child: Node in shop.get_children():
		if not child is SkillSlot: continue
		(child as SkillSlot).clear()
	var available_items_cpy: Array[ItemCurrentData] = available_items.duplicate()
	for i: int in items_per_rerol:
		if available_items_cpy.is_empty():
			break
		var item: ItemCurrentData = available_items_cpy.pick_random()
		available_items_cpy.remove_at(available_items_cpy.find(item))
		if not shop.try_drop_skill(item, true, false, 0, func(_data: ItemCurrentData) -> void: page_adventure.next_event()):
			break
	shop.drop_disabled = true
	shop.call_deferred("center_items")

func _rerol_shop() -> void:
	if AdventureResources.coins < rerol_starting_cost: return
	AdventureResources.coins -= rerol_starting_cost
	rerol_starting_cost += 1
	refil_shop()

func _init_items() -> void:
	if force_avaible_and_ignore_filter: return
	if use_character_collection_filter:
		item_filter.collections = [AdventureResources.character]
		item_filter.filter_collection = true
	available_items.clear()
	for item: SkillData in adventure_data.all_items:
		if item.is_generated_item: 
			continue
		if item_filter == null or item_filter.validate(item):
			var item_current_data: ItemCurrentData = ItemCurrentData.new()
			var tier: SkillData.Tier = min(int(item.starting_tier) + randi_range(0, tier_upgrade + 1), int(SkillData.Tier.DIAMOND)) as SkillData.Tier
			item_current_data.init(item, tier)
			available_items.append(item_current_data)
