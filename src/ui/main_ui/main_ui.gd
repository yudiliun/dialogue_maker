extends Control

@onready var scene_name_label: Label = $scene_name
@onready var edit_dial_input: TextEdit = $edit_dial_input
@onready var br_idx_label: Label = $idx
@onready var seq_idx_label: Label = $seq_label
@onready var list_container: VBoxContainer = $sent_container/list_container

func _ready() -> void:
	scene_name_label.text = Data.cur_scene_name
	Data.connect("dialogue_changed", refresh_text)
	Data.connect("dialogue_changed", update_sent_btn)
	edit_dial_input.connect("text_changed", func():
		Data.cur_seq_sent["sentence"] = edit_dial_input.text
	)
	update_sent_btn()
	refresh_text()

func new_dial_seq() -> void:
	var new_popup :PopUp = Core.popup(Core.popup_ui_list.popup)
	new_popup.message = "Do you want to make new dialogue sequence?"
	new_popup.connect("OK", func(): 
			Data.new_seq(Data.cur_dial_branch.get("br_idx") + 1)
			Data.change_seq(1)
	)

func refresh_text() -> void:
	edit_dial_input.text = Data.cur_seq_sent.get("sentence")
	br_idx_label.text = str(Data.cur_dial_branch.get("br_idx")) + "/" + str(Data.cur_dial_branch.get("size") - 1)
	seq_idx_label.text = str(Data.cur_dial_seq.get("seq_idx")) + "/" + str(Data.cur_dial_seq.get("size") - 1)

func update_sent_btn() -> void:
	var buttons :Array = list_container.get_children()
	var btn_buf :Array = []
	var dif :int = buttons.size() - Data.cur_dial_seq.get("size")
	if dif == 0:
		return
	if dif > 0:
		for i in range(dif):
			var btn :Button = buttons[buttons.size() - 1]
			list_container.remove_child(btn)
			btn.queue_free()
			buttons = list_container.get_children()
	elif dif < 0:
		for i in range(abs(dif)):
			var new_button :Button = Button.new()
			btn_buf.append(new_button)
	for btn in btn_buf:
		btn.text = str(buttons.size())
		btn.add_theme_font_size_override("font_size", 25)
		btn.connect("button_up", func():
			Data.change_sent(int(btn.text))
		)
		#list_container.call_deferred("add_child", btn)
		list_container.add_child(btn)
		buttons = list_container.get_children()

func _on_back_button_up() -> void:
	Data.save_data(Data.cur_scene_list.get(Data.cur_scene_name), Data.cur_dialogue_scene)
	Core.change_ui(Core.ui_list.dialogue_workspace)

func _on_adv_button_up() -> void:
	if !(str(Data.cur_dial_branch.get("br_idx") + 1)) in Data.cur_dial_branch:
		new_dial_seq()
		return
	Data.change_seq(1)

func _on_prev_button_up() -> void:
	Data.change_seq(-1)

func _on_del_button_up() -> void:
	if Data.cur_dial_branch.get("size") == 1:
		var new_popup :PopUp = Core.popup(Core.popup_ui_list.popup)
		new_popup.message = "There must be at least 1 dialogue sequence!"
		new_popup.cancel_visible = false
		return
	var del_popup :PopUp = Core.popup(Core.popup_ui_list.popup)
	del_popup.message = "Do you want to delete this dialogue sequence?"
	del_popup.connect("OK", func():
		Data.del_seq()
	)

func _on_insert_button_up() -> void:
	var ins_popup :PopUp = Core.popup(Core.popup_ui_list.popup)
	ins_popup.message = "Do you want to insert new dialogue sequence at index " + str(Data.cur_dial_branch.get("br_idx")) +"?"
	ins_popup.connect("OK", func():
		Data.ins_seq()
	)

func _on_add_seq_button_up() -> void:
	Data.new_sent(Data.cur_dial_seq.get("size"))

func _on_delete_sent_button_up() -> void:
	if Data.cur_dial_seq.get("size") == 1:
		var new_popup :PopUp = Core.popup(Core.popup_ui_list.popup)
		new_popup.message = "There must be at least 1 dialogue sentence!"
		new_popup.cancel_visible = false
		return
	var del_popup :PopUp = Core.popup(Core.popup_ui_list.popup)
	del_popup.message = "Do you want to delete this dialogue sentence?"
	del_popup.connect("OK", func():
		Data.del_sent()
	)

func _on_insert_sent_button_up() -> void:
	var ins_popup :PopUp = Core.popup(Core.popup_ui_list.popup)
	ins_popup.message = "Do you want to insert new dialogue sentence at index " + str(Data.cur_dial_seq.get("seq_idx")) +"?"
	ins_popup.connect("OK", func():
		Data.ins_sent()
	)
