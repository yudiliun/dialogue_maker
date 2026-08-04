extends Control

@onready var chr_name: RichTextLabel = $chr_name
@onready var emotion_list: VBoxContainer = $emotion_list_container/emotion_list
@onready var emotion_name: Label = $emotion_name
@onready var fd_open: FileDialog = $fd_open

var cur_emotion :String:
	set(value):
		cur_emotion = value
		emotion_name.text = value

func _ready() -> void:
	fd_open.current_dir = OS.get_environment("USERPROFILE")
	fd_open.visible = true
	Data.connect("emotion_added", add_emo_btn)
	Data.connect("emotion_deleted", del_emo_btn)
	Data.connect("emotion_renamed", ren_emo_btn)
	Data.connect("chr_renamed", func(new_name :String):
		chr_name.text = new_name
	)
	chr_name.text = Data.cur_chr_info.get("name")
	for emotion in Data.cur_chr_info.get("emotions"):
		add_emo_btn(emotion)

func find_emo_btn(emo_name) -> Button:
	var btn_idx :int = emotion_list.get_children().find_custom(func(button :Button):
		return button.name == emo_name
	)
	if btn_idx < 0:
		return null
	return emotion_list.get_children().get(btn_idx)

func ren_emo_btn(old_name :String, new_name :String) -> void:
	var btn :Button = find_emo_btn(old_name)
	btn.name = new_name
	btn.text = new_name
	cur_emotion = new_name

func add_emo_btn(emo_name :String) -> void:
	var new_btn :Button = Button.new()
	new_btn.name = emo_name
	new_btn.text = emo_name
	new_btn.add_theme_font_size_override("font_size", 25)
	new_btn.connect("button_up", func():
		cur_emotion = new_btn.text
	)
	emotion_list.call_deferred("add_child", new_btn)

func del_emo_btn(emo_name :String) -> void:
	cur_emotion = ""
	find_emo_btn(emo_name).queue_free()
	

func _on_back_button_up() -> void:
	Data.save_data(Data.cur_chr_list.get(Data.cur_chr_info.get("name")), Data.cur_chr_info)
	Core.change_ui(Core.ui_list.dialogue_workspace)

func _on_add_e_button_up() -> void:
	var new_popup :PopUp = Core.popup(Core.popup_ui_list.line_edit)
	new_popup.message = "Add new emotion"
	new_popup.connect("submit", func(emo_name :String, popup :PopUp):
		if emo_name in Data.cur_chr_info.get("emotions"):
			var ex_popup :PopUp = Core.popup(Core.popup_ui_list.popup)
			ex_popup.message = "Emotion already exist"
			ex_popup.cancel_visible = false
			return
		Data.add_emotion(emo_name)
		popup.can_free = true
	)

func _on_delete_e_button_up() -> void:
	if cur_emotion == "":
		return
	var new_popup :PopUp = Core.popup(Core.popup_ui_list.popup)
	new_popup.message = "Are you sure you want to delete this emotion?"
	new_popup.connect("OK", func():
		Data.del_emotion(cur_emotion)
	)

func _on_rename_e_button_up() -> void:
	if cur_emotion == "":
		return
	var new_popup :PopUp = Core.popup(Core.popup_ui_list.line_edit)
	new_popup.message = "Rename emotion"
	new_popup.button_text = "Rename"
	new_popup.connect("submit", func(emo_name :String, popup :PopUp):
		if emo_name in Data.cur_chr_info.get("emotions"):
			var ex_popup :PopUp = Core.popup(Core.popup_ui_list.popup)
			ex_popup.message = "Emotion already exist"
			ex_popup.cancel_visible = false
			return
		Data.rename_emotion(cur_emotion, emo_name)
		popup.can_free = true
	)


func _on_rename_chr_button_up() -> void:
	var new_popup :PopUp = Core.popup(Core.popup_ui_list.line_edit)
	new_popup.message = "Rename character"
	new_popup.button_text = "Rename"
	new_popup.connect("submit", func(new_name :String, popup :PopUp):
		if new_name == Data.cur_chr_info.get("name"):
			var ex_popup :PopUp = Core.popup(Core.popup_ui_list.popup)
			ex_popup.message = "New name is the same as old name"
			ex_popup.cancel_visible = false
			return
		Data.rename_chr(new_name)
		popup.can_free = true
	)
