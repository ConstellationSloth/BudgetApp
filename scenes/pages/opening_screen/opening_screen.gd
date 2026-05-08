extends Control
class_name OpeningScreen
@onready var month_view_button = $CenterContainer/VBoxContainer/MonthView
@onready var expense_category_configuration_button = $CenterContainer/VBoxContainer/ExpenseCategoryConfiguration

signal month_view_selected
signal expense_category_configuration_selected

func _ready():
	month_view_button.pressed.connect(month_view_selected.emit)
	expense_category_configuration_button.pressed.connect(expense_category_configuration_selected.emit)
