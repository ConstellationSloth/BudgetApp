extends VBoxContainer
class_name MonthView

@onready var back_button : Button = $HBoxContainer/BackButton
@onready var date_selector : DateSelector = $TopRow/DateSelector
@onready var expense_view : ExpenseView = $TopRow/TabContainer/Expenses
#@onready var income_view = $TopRow/TabContainer/Income
#@onready var net_view = $TopRow/TabContainer/Net
@onready var add_transaction_view: AddTransactionView = $"TabContainer/Add Transaction"

signal back_pressed

var month: Month
var selected_day : int
func _ready():
	date_selector.date_changed.connect(date_changed_pass)
	back_button.pressed.connect(back_pressed.emit)
	selected_day = date_selector.selected_day
	var month_idx = date_selector.selected_month
	var year = date_selector.selected_year
	load_month(selected_day, month_idx, year)
	add_transaction_view.day = selected_day
	add_transaction_view.transactions_created.connect(add_transactions)

func date_changed_pass(day_idx: int, month_idx: int, year: int) -> void:
	EventBus.date_changed.emit(day_idx, month_idx, year)
	load_month(day_idx, month_idx, year)

func add_transactions(transactions: Array[Transaction], category_names: Array[String]) -> void:
	print("adding transactions")
	var category = month.expenses
	for idx in range(1,len(category_names)):
		var category_name = category_names[idx]
		var found = false
		print("in category %s and looking for a category named %s" % [category.name, category_name])
		for subcategory in category.subcategories:
			if subcategory.name == category_name:
				found = true
				category = subcategory
				break
		print(found)
		if not found:
			var new_category = Category.new()
			new_category.name = category_name
			category.subcategories.append(new_category)
			category = new_category
	print(len(month.expenses.subcategories))
	category.transactions.append_array(transactions)
	initiate_month()
	month.save()

func initiate_month():
	expense_view.month = month
	expense_view.refresh_month()

func load_month(day: int, month_idx: int, year: int):
	if month == null:
		month = Month.load_or_create(year, month_idx)
		initiate_month()
		return
	if month_idx != month.idx || year != month.year:
		month = Month.load_or_create(year, month_idx)
		initiate_month()
	else:
		if day == selected_day:
			return
		
