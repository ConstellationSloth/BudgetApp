extends HBoxContainer
class_name AddTransactionView

const TRANSACTION_ROW_PATH = "uid://b1kxcu2i3rc4t"

@onready var new_transaction_button : Button = $ScrollContainer/TransactionBox/TransactionList/NewTransaction
@onready var create_transactions_button : Button = $ScrollContainer/TransactionBox/CreateTransactions
@onready var transaction_list : VBoxContainer = $ScrollContainer/TransactionBox/TransactionList
@onready var tree: CategoryTree = $Tree

signal transactions_created(transactions: Array[Transaction], category_names: Array[String])

var day = 1

func on_date_changed(new_day: int, _new_month: int, _new_year: int) -> void:
	day = new_day

func _ready():
	new_transaction_button.pressed.connect(add_transaction_row)
	create_transactions_button.pressed.connect(create_transactions)
	EventBus.date_changed.connect(on_date_changed)

func clear_transactions():
	var count = transaction_list.get_child_count()
	for i in range(count-1):
		transaction_list.remove_child(transaction_list.get_child(0))

func add_transaction_row():
	var transaction_row = load(TRANSACTION_ROW_PATH).instantiate()
	transaction_list.add_child(transaction_row)
	transaction_list.move_child(transaction_row, -2)

func create_transactions():
	var selected = tree.get_selected()
	if selected == null || transaction_list.get_child_count() == 1:
		return
	var category_names: Array[String] = []
	while selected != null:
		category_names.push_front(selected.get_metadata(0).name)
		selected = selected.get_parent()
	var transactions: Array[Transaction] = []
	for idx in range(transaction_list.get_child_count()-1):
		var child : TransactionRow = transaction_list.get_child(idx)
		var transaction = Transaction.new()
		transaction.value = child.get_value()
		transaction.day = day
		transactions.append(transaction)
	transactions_created.emit(transactions, category_names)
	clear_transactions()
	
	
