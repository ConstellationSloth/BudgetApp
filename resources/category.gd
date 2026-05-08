extends Resource
class_name Category

@export var subcategories: Array[Category] = []
@export var transactions: Array[Transaction] = []
@export var name : String

func name_sort_subcategories(recursive : bool = false) -> void:
	subcategories.sort_custom(compare_by_name)
	if recursive:
		for category in subcategories:
			category.name_sort_subcategories(true)

func get_amt_sorted_subcategories() -> Array[Category]:
	var clone = subcategories.duplicate(false)
	clone.sort_custom(compare_by_amt)
	return clone

static func compare_by_name(cat1: Category, cat2: Category):
	return cat1.name < cat2.name

static func compare_by_amt(cat1: Category, cat2: Category):
	return cat1.calculate_expense() >= cat2.calculate_expense()

func delete(category: Category):
	for idx in range(len(subcategories)):
		var subcategory = subcategories[idx]
		if subcategory.name == category.name:
			subcategories.remove_at(idx)
			return

func calculate_expense() -> float:
	var expense : float = 0.0
	for category in subcategories:
		expense += category.calculate_expense()
	for transaction in transactions:
		expense += transaction.value
	return expense
