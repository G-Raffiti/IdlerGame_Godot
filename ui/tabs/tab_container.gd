extends HBoxContainer

@export var tabs_unlock_data: Array[TabUnlock_Data]

func _ready() -> void:
	for tab_unlock in tabs_unlock_data:
		var button: Button = get_node(tab_unlock.tab_button) as Button
		if button == null:
			continue
		button.pressed.connect(func() -> void: display_page(get_node(tab_unlock.page_to_open)))
	display_page(null)
	RS.on_current_boss_level_changed.connect(update_lock_state)
	update_lock_state(RS.current_boss_level)

func display_page(in_page_to_open: PageBase) -> void:
	for tab_unlock in tabs_unlock_data:
		var button: Button = get_node(tab_unlock.tab_button) as Button
		if button == null:
			continue
		var page: PageBase = get_node(tab_unlock.page_to_open) as PageBase
		if page == null:
			continue
		if page == in_page_to_open:
			page.visible = true
			button.button_pressed = true
			page.open_page()
		else:
			page.visible = false
			button.button_pressed = false
			page.close_page()

func update_lock_state(in_current_boss_level: int) -> void:
	for tab_unlock in tabs_unlock_data:
		var button: Button = get_node(tab_unlock.tab_button) as Button
		if button == null:
			continue
		if tab_unlock.unlock_boss_level > in_current_boss_level:
			button.disabled = true
			button.text = "Locked"
			button.tooltip_text = "Unlocked at Boss Level " + str(tab_unlock.unlock_boss_level)
		else:
			button.disabled = false
			button.text = tab_unlock.page_name
			button.tooltip_text = tab_unlock.page_tooltip
