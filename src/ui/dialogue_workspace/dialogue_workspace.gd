extends Control

@onready var dialogue_title: Label = $dialogue_title
@onready var scene_list_container: VBoxContainer = $scene_list_container/scene_list/list_container

const sc_uid :String = "uid://btlwvn74idpkd"

func _ready() -> void:
	Data.cur_scene_name = ""
	Data.cur_dialogue_scene.clear()
	dialogue_title.text = Data.cur_dialogue_workspc
	for scene in Data.cur_scene_list:
		add_list(scene.get_file().get_basename())

func _on_back_button_up() -> void:
	Data.cur_dialogue_workspc = ""
	Core.change_ui(Core.ui_list.workspace_list)

func add_list(s_name :String) -> void:
	var sc_scene :PackedScene = load(sc_uid)
	var new_sc = sc_scene.instantiate()
	new_sc.scene_name = s_name
	scene_list_container.call_deferred("add_child", new_sc)

func add_scene(s_name :String, popup :PopUp) -> void:
	if Data.cur_scene_list.has(s_name):
		var new_popup :PopUp = Core.popup(Core.popup_ui_list.popup)
		new_popup.message = "Scene of the same name already exist!"
		new_popup.cancel_visible = false
		return
	Data.add_scene(s_name)
	add_list(s_name)
	popup.can_free = true

func _on_scene_add_new_button_up() -> void:
	var new_popup :PopUp = Core.popup(Core.popup_ui_list.line_edit)
	new_popup.message = "Add new scene"
	new_popup.connect("submit", add_scene)
