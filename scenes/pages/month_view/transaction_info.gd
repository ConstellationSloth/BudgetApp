extends MarginContainer
class_name TransactionInfo

@onready var amount_label = $HBoxContainer/Amount
@onready var day_label = $HBoxContainer/Day
@onready var delete_button = $HBoxContainer/DeleteButton
@onready var percentage_label = $HBoxContainer/Percentage
var transaction : Transaction
var total : float

signal deleted

func _ready():
	delete_button.pressed.connect(on_delete)
	day_label.text = "%d%s" % [transaction.day, Calendar.get_day_letters(transaction.day)]
	percentage_label.text = str(round((transaction.value/total)*100)) + "%"
	amount_label.text = "$ %0.2f" % transaction.value

func on_delete():
	deleted.emit(transaction)
