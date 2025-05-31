extends Adventure_EventData
class_name Adventure_EventData_Shop

var adventure_data: AdventureData:
	get: 
		if adventure_data == null:
			adventure_data = preload("uid://b7kbibmnhimhg")
		return adventure_data

@export_group("Shop/Available Items")
@export var item_filter: ItemFilter
@export var use_character_collection_filter: bool
@export var force_avaible_and_ignore_filter: bool
@export var tier_upgrade: int = 0
@export var available_items: Array[ItemCurrentData] = []

@export_group("Shop/Rerol")
@export var rerol_num: int = 1
@export var items_per_rerol: int = 3
@export var rerol_cost: int = 4

var shop: Board
var interact_button: ButtonRich

func initialize(in_tabs: TabContainer, in_interact_button: ButtonRich, in_leave_button: ButtonRich) -> void:
	_init_items()
	in_tabs.current_tab = Adventure.TAB_INDEX_SHOP
	shop = in_tabs.get_child(Adventure.TAB_INDEX_SHOP)
	interact_button = in_interact_button
	SignalBus.clear_signal(interact_button.pressed)
	interact_button.pressed.connect(_rerol_shop)
	interact_button.button_text = "Rerol \n(" + str(rerol_cost) + "[b][color=gold]Coins[/color][/b])"
	interact_button.disabled = false
	SignalBus.clear_signal(in_leave_button.pressed)
	in_leave_button.pressed.connect(page_adventure.next_event)
	in_leave_button.button_text = "Next Event"
	in_leave_button.disabled = false
	refil_shop()

func refil_shop() -> void:
	shop.drop_disabled = false
	shop.clear_board()
	var available_items_cpy: Array[ItemCurrentData] = available_items.duplicate()
	for i: int in items_per_rerol:
		if available_items_cpy.is_empty():
			break
		var item: ItemCurrentData = available_items_cpy.pick_random()
		available_items_cpy.remove_at(available_items_cpy.find(item))
		if not shop.try_drop_skill(item, true, false, item.data.size * 2 * int(item.tier)):
			break
	shop.drop_disabled = true
	shop.call_deferred("center_items")

func _rerol_shop() -> void:
	if rerol_num <= 0: return
	if AdventureResources.coins < rerol_cost: return
	AdventureResources.coins -= rerol_cost
	rerol_num -= 1
	if rerol_num <= 0:
		interact_button.disabled = true
		interact_button.button_text = ""
	refil_shop()

func _init_items() -> void:
	if force_avaible_and_ignore_filter: return
	if use_character_collection_filter:
		item_filter.collections = [AdventureResources.character]
		item_filter.filter_collection = true
	available_items.clear()
	for item: SkillData in adventure_data.all_items:
		if item_filter == null || item_filter.validate(item):
			var item_current_data: ItemCurrentData = ItemCurrentData.new()
			var tier: SkillData.Tier = min(int(item.starting_tier) + randi_range(0, tier_upgrade + 1), int(SkillData.Tier.DIAMOND)) as SkillData.Tier
			item_current_data.init(item, tier)
			available_items.append(item_current_data)
