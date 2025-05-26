extends Resource
class_name Adventure_EventData

const TAB_INDEX_CHEST: int = 0
const TAB_INDEX_MONSTER_BOARD: int = 1
const TAB_INDEX_SHOP: int = 2
const TAB_INDEX_EVENT_CHOICE: int = 3
const TAB_INDEX_EVENT_BUTTON_CONTAINER: int = 4

var page_adventure: PageAdventure = null
var combat_manger: Combat = null

@export_group("Display") 
@export var title: String
@export_multiline var tooltip_text: String

func inject_dependencies(in_page_adventure: PageAdventure, in_combat_manger: Combat) -> void:
    page_adventure = in_page_adventure
    combat_manger = in_combat_manger

func initialize(in_tabs: TabContainer, in_interact_button: ButtonRich, in_leave_button: ButtonRich) -> void:
    pass