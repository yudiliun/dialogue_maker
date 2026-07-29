extends NinePatchRect

@onready var scene_name_label: Label = $scene_name

var scene_name :String = ""

func _ready() -> void:
	scene_name_label.text = scene_name

func delete_scene() -> void:
	Data.del_scene(scene_name)
	queue_free()

func _on_delete_button_up() -> void:
	var new_popup :PopUp = Core.popup(Core.popup_ui_list.popup)
	new_popup.message = "Are you sure you want to delete this scene?"
	new_popup.connect("OK", delete_scene)

func _on_edit_button_up() -> void:
	Data.cur_scene_name = scene_name
	Data.dial_scene_init()
	Core.change_ui(Core.ui_list.main_ui)


func _on_rename_button_up() -> void:
	var ren_popup :PopUp = Core.popup(Core.popup_ui_list.line_edit)
	ren_popup.button_text = "Rename"
	ren_popup.message = "Rename scene"
	ren_popup.connect("submit", func(new_name :String, popup :PopUp):
		if Data.cur_scene_list.has(new_name):
			var new_popup :PopUp = Core.popup(Core.popup_ui_list.popup)
			new_popup.message = "Scene of the same name already exist!"
			new_popup.cancel_visible = false
			return
		var ren_error :Error = Data.rename_filedir(Data.scene_path, scene_name, new_name, Data.cur_scene_list, ".json")
		if ren_error == Error.OK:
			scene_name = new_name
			scene_name_label.text = scene_name
			popup.can_free = true
	)
