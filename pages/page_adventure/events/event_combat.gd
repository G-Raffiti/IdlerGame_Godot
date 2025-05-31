extends Adventure_EventData
class_name Adventure_EventData_Combat

@export_group("Combat")
@export var adventurer: Adventurer

var interact_button: ButtonRich
var leave_button: ButtonRich

func customise_event_button(in_button: ButtonImage) -> void:
	in_button.image = icon
	in_button.text_tooltip = "[b][color=tomato][u]" + title + "[/u][/color]:[/b]\n" + \
	"[color=green_yellow]" + str(adventurer.max_hp) + " [b]HP[/b][/color]\n\n" + \
	"[b]Rewards:[/b]\n" + \
	"+" + str(adventurer.reward[Adventurer.CombatResource.COINS]) + " [color=gold]Coins[/color]\n" + \
	"+" + str(adventurer.reward[Adventurer.CombatResource.XP]) + " [color=plum]XP[/color]\n" + \
	"steal 1 Item or passive Power"

func initialize(in_tabs: TabContainer, in_interact_button: ButtonRich, in_leave_button: ButtonRich) -> void:
	_init_board(in_tabs.get_child(Adventure.TAB_INDEX_MONSTER_BOARD))
	interact_button = in_interact_button
	leave_button = in_leave_button
	in_tabs.current_tab = Adventure.TAB_INDEX_MONSTER_BOARD
	SignalBus.clear_signal(in_interact_button.pressed)
	in_interact_button.button_text = "Combat Speed\nx %.2f" % Engine.time_scale
	in_interact_button.pressed.connect(_cycle_combat_speed)
	SignalBus.clear_signal(in_leave_button.pressed)
	in_leave_button.pressed.connect(_start_combat, CONNECT_ONE_SHOT)
	in_leave_button.button_text = "[b][font_size=27]Fight[/font_size][/b]"
	in_leave_button.disabled = false
	combat_manger.on_combat_ends.connect(_on_combat_ends)

func _cycle_combat_speed() -> void:
	if Engine.time_scale < 1.25:
		Engine.time_scale = 1.25
	elif Engine.time_scale < 1.5:
		Engine.time_scale = 1.5
	elif Engine.time_scale < 2.0:
		Engine.time_scale = 2.0
	elif Engine.time_scale < 3.0:
		Engine.time_scale = 3.0
	elif Engine.time_scale < 5.0:
		Engine.time_scale = 5.0
	else:
		Engine.time_scale = 1.0
	interact_button.button_text = "Combat Speed\nx %.2f" % Engine.time_scale

func _start_combat() -> void:
	leave_button.disabled = true
	adventurer.hp = adventurer.max_hp
	combat_manger.start_combat(adventurer)

func _on_combat_ends(in_is_victory: bool) -> void:
	AdventureResources.coins += adventurer.reward[Adventurer.CombatResource.COINS]
	if in_is_victory == true:
		leave_button.button_text = "[b]Reward[/b]"
		leave_button.pressed.connect(_go_to_reward, CONNECT_ONE_SHOT)
	else:
		SignalBus.clear_signal(leave_button.pressed)
		leave_button.button_text = "Next Event"
		leave_button.pressed.connect(func() -> void: combat_manger.exit_combat(); page_adventure.next_event())
	leave_button.disabled = false

func _go_to_reward() -> void:
	combat_manger.exit_combat()
	AdventureResources.xp += adventurer.reward[Adventurer.CombatResource.XP]
	page_adventure.tabs.current_tab = Adventure.TAB_INDEX_SHOP
	var shop: Board = page_adventure.tabs.get_child(Adventure.TAB_INDEX_SHOP)
	shop.drop_disabled = false
	for child: Node in shop.get_children():
		if not child is SkillSlot: continue
		(child as SkillSlot).clear()
	var item_ref: Adventurer_ItemTier = adventurer.board.pick_random()
	var item: ItemCurrentData = ItemCurrentData.new()
	item.init(item_ref.item, item_ref.tier)
	shop.try_drop_skill(item, true, false, 0, func(_data: ItemCurrentData) -> void: page_adventure.next_event())
	shop.call_deferred("center_items")
	shop.drop_disabled = true

func _init_board(in_monster_board: Board) -> void:
	in_monster_board.drop_disabled = false
	for item_ref: Adventurer_ItemTier in adventurer.board:
		var item: ItemCurrentData = ItemCurrentData.new()
		item.init(item_ref.item, item_ref.tier)
		in_monster_board.try_drop_skill(item, false, false)
	in_monster_board.drop_disabled = true
	in_monster_board.drag_disabled = true
	in_monster_board.call_deferred("center_items")
