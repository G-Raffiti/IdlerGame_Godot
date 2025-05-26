extends Adventure_EventData
class_name Adventure_EventData_GainOneItem

@export var available_items: Array[SkillData]
@export var items_per_rerol: int = 3

var shop: Board

func initialize(in_tabs: TabContainer, in_interact_button: ButtonRich, in_leave_button: ButtonRich) -> void:
    in_tabs.current_tab = TAB_INDEX_SHOP
    shop = in_tabs.get_child(TAB_INDEX_SHOP).get_child(1)
    SignalBus.clear_signal(in_interact_button.pressed)
    in_interact_button.disabled = true
    in_interact_button.button_text = ""
    SignalBus.clear_signal(in_leave_button.pressed)
    in_leave_button.button_text = "Next Event"
    in_leave_button.pressed.connect(page_adventure.next_event)

func refil_shop() -> void:
    for child: Node in shop.get_children():
        if not child is SkillSlot: continue
        (child as SkillSlot).clear()
    var available_items_cpy: Array[SkillData] = available_items.duplicate()
    for i: int in items_per_rerol:
        var data: SkillData = available_items_cpy.pick_random()
        available_items_cpy.remove_at(available_items_cpy.find(data))
        if not shop.try_drop_skill(data, true, false, data.cost, func(_data: SkillData) -> void: page_adventure.next_event()):
            break
    shop.drop_disabled = true
