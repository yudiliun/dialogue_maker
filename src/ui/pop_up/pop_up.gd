extends Panel
class_name PopUp

signal OK
signal CANCEL

@export var msg_label: Label
@export var cancel_button: Button
@export var confirm_button :Button
@export var msg_dist_to_bottom :int

var message :String
var cancel_visible :bool = true

func _ready() -> void:
	msg_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	msg_label.text = message
	if !cancel_visible:
		cancel_button.visible = false
	confirm_button.connect("button_up", confirm_button_up)
	cancel_button.connect("button_up", cancel_button_up)
	msg_label.connect("maximum_size_changed", msg_label_maximum_size_changed)

func confirm_button_up() -> void:
	OK.emit()
	queue_free()


func cancel_button_up() -> void:
	CANCEL.emit()
	queue_free()


func msg_label_maximum_size_changed() -> void:
	var new_size :Vector2 = Vector2(size.x, (msg_label.size.y + msg_dist_to_bottom))
	size = new_size
	position.y = (get_window().size.y/2.0) - (size.y/2.0)
