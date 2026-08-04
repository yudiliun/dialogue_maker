extends Control

@onready var temp: RichTextLabel = $temp

#temp
var dic1 :Dictionary = {
	"val" : "dic1",
}

var dic2 :Dictionary = {
	"val" : "dic2"
}

func _ready() -> void:
	temp.text = "[b][color=black]Save path (temp) : " + Data.path +" [/color][/b]"
	var new_btn :Button= Button.new()
	new_btn.name = "testing"
	var testarr :Array
	testarr.append(new_btn)
	print(testarr.find_custom(func(button :Button):
		return button.name == "testing"
	))

func _on_exit_button_up() -> void:
	Core.quit_game()


func _on_dialogues_button_up() -> void:
	Core.change_ui(Core.ui_list.workspace_list)
