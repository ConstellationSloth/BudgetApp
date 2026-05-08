extends Tree
class_name CategoryTree

const MAIN_EXPENSE_TITLE = "Main Expense Categories"

@export var category_edit : bool = false
const user_directory_path = "user://"
const expense_category_path = user_directory_path + "expense_categories.tres"
var expense_configuration: Category

func reset_tree():
	clear()
	create_tree(category_edit, expense_configuration)

func create_tree(show_root: bool, category: Category):
	var root : TreeItem = create_item()
	root.set_metadata(0, category)
	if show_root:
		root.set_text(0, category.name)
		root.set_disable_folding(true)
	else:
		set_hide_root(true)
	for subcategory in category.subcategories:
		create_category_item(subcategory, root, !show_root)

func create_category_item(category : Category, parent : TreeItem, set_high_level_disabled: bool) -> TreeItem:
	var category_item = create_item(parent)
	category_item.set_text(0, category.name)
	category_item.set_metadata(0, category)
	if len(category.subcategories) > 0:
		for subcategory in category.subcategories:
			create_category_item(subcategory, category_item, set_high_level_disabled)
		if set_high_level_disabled:
			category_item.set_selectable(0, false)
		#category_item.collapsed = true
	return category_item

func make_category(category_name: String, parent_category: Category) -> Category:
	var category = Category.new()
	category.name = category_name
	parent_category.subcategories.append(category)
	return category

func make_main_category(category_name: String, arr: Array[Category]) -> Category:
	var category = Category.new()
	category.name = category_name
	arr.append(category)
	return category

func create_default_expense_categories() -> Category:
	var categories : Array[Category] = []
	var bills = make_main_category("Bills", categories)
	make_category("Rent", bills)
	var insurance = make_category("Insurance", bills)
	make_category("Car Insurance", insurance)
	make_category("Renters Insurance", insurance)
	make_category("Health Insurance", insurance)
	make_category("Phone", bills)
	var utilities = make_category("Utilities", bills)
	make_category("Internet", utilities)
	make_category("Water", utilities)
	make_category("Heat", utilities)
	make_category("Electricity", utilities)
	make_category("Trash", utilities)
	var food = make_main_category("Food", categories)
	make_category("Groceries", food)
	make_category("Snacks", food)
	make_category("Eating out", food)
	var travel = make_main_category("Travel", categories)
	make_category("Gas", travel)
	make_category("Rideshare", travel)
	var expense_categories = Category.new()
	expense_categories.name = MAIN_EXPENSE_TITLE
	expense_categories.subcategories = categories
	expense_categories.name_sort_subcategories(true)
	return expense_categories

func save_configuration() -> void:
	ResourceSaver.save(expense_configuration, expense_category_path)

func has_configuration() -> bool:
	var user_dir = DirAccess.open(user_directory_path)
	return user_dir.file_exists(expense_category_path)

func load_configuration() -> Category:
	var expense_categories : Category = ResourceLoader.load(expense_category_path)
	return expense_categories

func _ready():
	set_columns(2)
	column_titles_visible = false
	select_mode = Tree.SELECT_ROW
	if !has_configuration():
		expense_configuration = create_default_expense_categories()
		save_configuration()
	else:
		expense_configuration = load_configuration()
	reset_tree()
	
