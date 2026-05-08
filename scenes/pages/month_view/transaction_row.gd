extends HBoxContainer
class_name TransactionRow

@onready var delete_button : Button = $DeleteTransaction
@onready var spin_box: SpinBox = $SpinBox

func _ready():
	delete_button.pressed.connect(queue_free)

func get_value():
	return spin_box.value
