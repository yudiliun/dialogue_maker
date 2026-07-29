extends Control

@onready var workspace_container: VBoxContainer = $workspace_list_container/workspace_list/workspace_container

#dlc = dialogue list container
const wc_uid :String = "uid://cups4ui5h0blh"

func _ready() -> void:
	for dialogue in Data.workspace_list:
		add_list(dialogue)

func add_list(d_name :String) -> void:
	var wc_scene :PackedScene = load(wc_uid)
	var new_wc :NinePatchRect= wc_scene.instantiate()
	new_wc.workspace_name = d_name
	workspace_container.call_deferred("add_child", new_wc)

func _on_back_button_up() -> void:
	Core.change_ui(Core.ui_list.main_menu)

func add(d_name :String, popup :PopUp) -> void:
	if Data.workspace_list.has(d_name):
		var new_popup :PopUp = Core.popup(Core.popup_ui_list.popup)
		new_popup.message = "Workspace of the same name already exist!"
		new_popup.cancel_visible = false
		return
	Data.add(d_name)
	add_list(d_name)
	popup.can_free = true

func _on_add_new_button_up() -> void:
	var add_new :PopUp = Core.popup(Core.popup_ui_list.line_edit)
	add_new.message = "Add new workspace"
	add_new.connect("submit", add)
