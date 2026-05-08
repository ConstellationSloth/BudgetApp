extends MarginContainer
class_name ExpenseButton

@onready var button : Button = $Button
@onready var name_label : Label = $HboxContainer/Name
@onready var percentage_label : Label =$HboxContainer/Percentage
@onready var amount_label : Label =$HboxContainer/Amount
var category: Category
var total : float
signal category_selected(category: Category)

func _ready():
	name_label.text = category.name
	var category_expense = category.calculate_expense()
	percentage_label.text = "%d%s" % [(round((category_expense / total) * 100)), "%"]
	amount_label.text = "$%0.2f" % category_expense
	button.pressed.connect(select_category)

func select_category() -> void:
	category_selected.emit(category)
