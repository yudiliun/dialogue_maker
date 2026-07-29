extends NinePatchRect

var workspace_name :String = ""
@onready var workspace_name_label: Label = $workspace_name

func _ready() -> void:
	workspace_name_label.text = workspace_name

func _on_del_button_up() -> void:
	var new_popup :Panel = Core.popup(Core.popup_ui_list.popup)
	new_popup.message = "Are you sure you want to delete this workspace?"
	new_popup.connect("OK", popup_ok)

func popup_ok() -> void:
	Data.remove(workspace_name)
	queue_free()

func _on_edit_button_up() -> void:
	Data.cur_dialogue_workspc = workspace_name
	Data.cur_dir_path = Data.path + "/" + workspace_name
	Data.workspc_init()
	Core.change_ui(Core.ui_list.dialogue_workspace)

func _on_rename_button_up() -> void:
	var ren_popup :PopUp = Core.popup(Core.popup_ui_list.line_edit)
	ren_popup.button_text = "Rename"
	ren_popup.message = "Rename workspace"
	ren_popup.connect("submit", func(new_name :String, popup :PopUp):
		if Data.workspace_list.has(new_name):
			var new_popup :PopUp = Core.popup(Core.popup_ui_list.popup)
			new_popup.message = "Workspace of the same name already exist!"
			new_popup.cancel_visible = false
			return
		var ren_error :Error = Data.rename_filedir(Data.path, workspace_name, new_name, Data.workspace_list)
		if ren_error == Error.OK:
			workspace_name = new_name
			workspace_name_label.text = workspace_name
			popup.can_free = true
		else:
			var err_popup :PopUp = Core.popup(Core.popup_ui_list.popup)
			err_popup.message = "Error : Please check if the folder is open in another program, close the program, and try again"
			err_popup.cancel_visible = false
	)
