extends Resource
class_name Month


@export var year : int
@export var idx : int
@export var income: Category
@export var expenses: Category 


static func _get_top_level_category(category_name: String) -> Category:
	var cat = Category.new()
	cat.name = category_name
	return cat

const USER_DIRECTORY = "user://"
const DATA_PATH = USER_DIRECTORY + "data/"
const YEAR_PATH = DATA_PATH + "%d/"
const MONTH_PATH = YEAR_PATH + "%d.tres"
func save():
	var user_dir = DirAccess.open(USER_DIRECTORY)
	var month_path = MONTH_PATH % [year, idx]
	var year_path = YEAR_PATH % year
	if user_dir.dir_exists(year_path):
		ResourceSaver.save(self, month_path)
	else:
		user_dir.make_dir(DATA_PATH)
		user_dir.make_dir(year_path)
		ResourceSaver.save(self, month_path)

static func load_or_create(target_year: int, target_month: int) -> Month:
	var user_dir = DirAccess.open(USER_DIRECTORY)
	if not user_dir.dir_exists(DATA_PATH):
		user_dir.make_dir(DATA_PATH)
	var year_path = YEAR_PATH % target_year
	if user_dir.dir_exists(year_path):
		var year_dir = DirAccess.open(year_path)
		if year_dir.file_exists(MONTH_PATH % [target_year, target_month]):
			return ResourceLoader.load(MONTH_PATH % [target_year, target_month])
		else:
			var month = Month.new()
			month.year = target_year
			month.idx = target_month
			month.expenses = _get_top_level_category("Expenses")
			month.income = _get_top_level_category("Income")
			return month
	else:
		var month = Month.new()
		month.expenses = _get_top_level_category("Expenses")
		month.income = _get_top_level_category("Income")
		month.year = target_year
		month.idx = target_month
		return month

func get_expense_total() -> float:
	var expense_total : float = 0
	for expense in expenses.subcategories:
		expense_total += expense.calculate_expense()
	return expense_total
	
func get_income_total() -> float:
	var income_total : float = income.calculate_expense()
	return income_total
