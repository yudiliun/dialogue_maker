extends Node

const scene_list :Dictionary = {
}

const ui_list :Dictionary = {
	"main_menu" : "uid://dcqyuhlqltwul",
	"main_ui" : "uid://h7hy0wekb7cm",
	"workspace_list" : "uid://svqwyvxnu2yx",
	"dialogue_workspace" : "uid://1arol4aoyd75",
	"chr_edit" : "uid://b01q346y7be4i"
}

const pause_ui_list :Dictionary = {
	
}

const popup_ui_list :Dictionary = {
	"popup" : "uid://c50xmdepo2uy8",
	"line_edit" : "uid://dg7vnni5sncqg"
}

@onready var Game: game = get_tree().current_scene

func change_scene_and_ui(scene_uid :String, ui_uid :String) -> void:
	Game.change_scene(scene_uid)
	Game.change_ui(ui_uid)

func change_scene(uid :String) -> void:
	Game.change_scene(uid)

func change_ui(uid :String) -> void:
	Game.change_ui(uid)

func pause(uid :String) -> void:
	Game.pause(uid)

func unpause() -> void:
	Game.unpause()

func quit_game() -> void:
	Game.quit_game()

func popup(uid :String, no_pause :bool = false) -> Control:
	return Game.popup(uid, no_pause)

func show_error(msg :String) -> void:
	Game.show_error(msg)

func ui_exist(uid :String) -> bool:
	if ui_list.find_key(uid) == null:
		return false
	return true

func scene_exist(uid :String) -> bool:
	if scene_list.find_key(uid) == null:
		return false
	return true
