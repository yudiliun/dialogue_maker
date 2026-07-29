extends Node
class_name game

@export var init_ui :String = ""
@export var init_scene :String = ""

#debug
@onready var err_bg: Panel = $debug/err_bg
@onready var err_label: Label = $debug/err_bg/err_label

@onready var scene_root :Node = $scene_root
@onready var ui_root :CanvasLayer = $ui_root
@onready var pause_root :CanvasLayer = $pause_root
@onready var popup_layer: CanvasLayer = $popup_layer
@onready var transition :CanvasLayer = $transition

var current_scene :Node2D = null
var current_ui :Control = null
var current_pause_ui :Control = null

func _ready() -> void:
	if init_ui == "":
		show_error("no init ui")
		return
	if !Core.ui_exist(init_ui):
		show_error("init ui not found")
		return
	change_ui(init_ui)
	if init_scene != "":
		if !Core.scene_exist(init_scene):
			show_error("init scene not found")
		else:
			change_scene(init_scene)

func _process(_delta: float) -> void:
	if Input.is_action_just_released("escape") && OS.is_debug_build():
		quit_game()

func change_scene_and_ui(scene_uid :String, ui_uid :String) -> void:
	change_scene(scene_uid)
	change_ui(ui_uid)

func change_scene(uid :String) -> void:
	if current_scene != null:
		current_scene.queue_free()
	var new_scene :PackedScene = load(uid)
	current_scene = new_scene.instantiate()
	scene_root.call_deferred("add_child", current_scene)

func change_ui(uid :String) -> void:
	if current_ui != null:
		current_ui.queue_free()
	var new_ui :PackedScene = load(uid)
	current_ui = new_ui.instantiate()
	ui_root.call_deferred("add_child", current_ui)

func pause(uid :String) -> void:
	get_tree().paused = true
	var new_pause_ui :PackedScene = load(uid)
	current_pause_ui = new_pause_ui.instantiate()
	pause_root.call_deferred("add_child", current_pause_ui)

func unpause() -> void:
	if current_pause_ui == null:
		get_tree().paused = false
		return
	current_pause_ui.queue_free()
	current_pause_ui = null
	get_tree().paused = false

#popup logic and signal is handled by the caller
func popup(uid :String, no_pause :bool = false) -> Control:
	if !no_pause:
		get_tree().paused = true
	var popup_scene :PackedScene = load(uid)
	var new_popup_ui :Control = popup_scene.instantiate()
	popup_layer.call_deferred("add_child", new_popup_ui)
	return new_popup_ui

func quit_game() -> void:
	get_tree().quit()

func show_error(msg :String) -> void:
	msg = "Error : " + msg
	push_error(msg)
	err_bg.visible = true
	err_label.text = msg

func _on_popup_layer_child_order_changed() -> void:
	var popups :Array[Node] = popup_layer.get_children()
	if popups.size() == 0:
		get_tree().paused = false
		return
	for i in popups.size():
		popups[i].process_mode = Node.PROCESS_MODE_PAUSABLE
		if i == popups.size() - 1:
			popups[i].process_mode = Node.PROCESS_MODE_ALWAYS  
