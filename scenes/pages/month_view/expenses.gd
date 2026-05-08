extends VBoxContainer
class_name ExpenseView

var expense_button_path = "uid://xdp8d6awchk7"
var transaction_info_path = "uid://bnhhjdk5iqy7w"
@onready var grid_container = $ScrollContainer/MarginContainer/HBoxContainer/GridContainer
@onready var back_button = $HBoxContainer/BackButton
@onready var title_label = $HBoxContainer/Title
@onready var amount_label = $HBoxContainer/Amount

var previous_categories : Array[Category] = []
var total: float
var month: Month
var current_category : Category
func _ready():
	back_button.pressed.connect(on_back_pressed)

func refresh_month():
	back_button.visible = false
	current_category = null
	title_label.text = "Total Monthly Expenses"
	total = month.get_expense_total()
	amount_label.text = "$%0.2f" % total
	#TODO: not this for top level
	set_category_list(month.expenses.get_amt_sorted_subcategories())
	previous_categories = []

func load_category_layout():
	back_button.visible = true
	title_label.text = current_category.name
	total = current_category.calculate_expense()
	amount_label.text = "$%0.2f" % total
	if len(current_category.subcategories) != 0:
		set_category_list(current_category.get_amt_sorted_subcategories())
	else:
		set_transaction_list(current_category.transactions)

func on_category_selected(cat: Category):
	if current_category != null:
		previous_categories.append(current_category)
	current_category = cat
	load_category_layout()

func set_transaction_list(transactions: Array[Transaction]) -> void:
	for child in grid_container.get_children():
		child.queue_free()
	for transaction in transactions:
		var transaction_info : TransactionInfo = load(transaction_info_path).instantiate()
		transaction_info.transaction = transaction
		transaction_info.total = total
		transaction_info.deleted.connect(on_transaction_deleted)
		grid_container.add_child(transaction_info)

func on_transaction_deleted(transaction: Transaction) -> void:
	var idx = current_category.transactions.find(transaction)
	if idx != -1:
		current_category.transactions.remove_at(idx)
	while current_category.calculate_expense() == 0:
		if len(previous_categories) == 0:
			idx = month.expenses.subcategories.find(current_category)
			if idx != -1:
				month.expenses.subcategories.remove_at(idx)
				month.save()
			refresh_month()
			return
		else:
			var parent_category = previous_categories.pop_back()
			idx = parent_category.subcategories.find(current_category)
			if idx != -1:
				parent_category.subcategories.remove_at(idx)
				month.save()
			current_category = parent_category
	if len(previous_categories) == 0:
			refresh_month()
			return
	if current_category.calculate_expense() == 0:
		pass
	load_category_layout()
	

func set_category_list(categories: Array[Category]) -> void:
	for child in grid_container.get_children():
		child.queue_free()
	for category in categories:
		var expense_button : ExpenseButton = load(expense_button_path).instantiate()
		expense_button.category = category
		expense_button.total = total
		expense_button.category_selected.connect(on_category_selected)
		grid_container.add_child(expense_button)
		
func on_back_pressed():
	if len(previous_categories) != 0:
		current_category = previous_categories.pop_back()
		load_category_layout()
	else:
		refresh_month()
