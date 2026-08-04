extends NinePatchRect

var chr_name :String
@onready var chr_name_label: RichTextLabel = $chr_name

func _ready() -> void:
	chr_name_label.text = chr_name

func _on_edit_button_up() -> void:
	Data.chr_info_init(chr_name)
	Core.change_ui(Core.ui_list.chr_edit)

func _on_delete_button_up() -> void:
	var new_popup :PopUp = Core.popup(Core.popup_ui_list.popup)
	new_popup.message = "Are you sure you want to delete this character?"
	new_popup.connect("OK", func():
		Data.del_chr(chr_name)
		queue_free()
	)
	
