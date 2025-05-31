extends Resource
class_name Adventure_EventData

var page_adventure: Adventure = null
var combat_manger: Combat = null

@export_group("Display") 
@export var icon: Texture2D
@export_multiline  var title: String
@export_multiline var tooltip_text: String

@export_group("Conditions")
@export var character_played: Array[SkillData.Collection] = [SkillData.Collection.PYGMALIEN, SkillData.Collection.DOOLEY, SkillData.Collection.VANESSA, SkillData.Collection.MAK, SkillData.Collection.JULES]

func inject_dependencies(in_page_adventure: Adventure, in_combat_manger: Combat) -> void:
    page_adventure = in_page_adventure
    combat_manger = in_combat_manger

func initialize(in_tabs: TabContainer, in_interact_button: ButtonRich, in_leave_button: ButtonRich) -> void:
    pass

func customise_event_button(in_button: ButtonImage) -> void:
    in_button.text_tooltip = tooltip_text
    in_button.image = icon
    in_button.text = title