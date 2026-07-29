extends PopUp

signal submit(name :String, self_ref :PopUp)

@onready var name_input: LineEdit = $input_container/name_input
@onready var add: Button = $button_container/add

var button_text :String = "Add"
var can_free :bool = false

func _ready() -> void:
	super()
	add.text = button_text

func confirm_button_up() -> void:
	if name_input.text == "":
		return
	submit.emit(name_input.text, self)
	if can_free:
		super()
