extends Panel

const MONTH_VIEW_PATH = "uid://cw4xcb5fh0k4c"
const EXPENSE_CATEGORY_CONFIGURATION_PATH = "uid://dueyc3j4cnhdr"
const OPENING_SCREEN_PATH = "uid://08g6jtrd2hh8"

const USER_DIRECTORY = "user://"
const version_file = USER_DIRECTORY + "version.json" 
func _ready():
	var user_dir = DirAccess.open(USER_DIRECTORY)
	if user_dir.file_exists(version_file):
		pass
	else:
		var data = {"version": .1}
		var data_string = JSON.stringify(data)
		var file = FileAccess.open(version_file, FileAccess.WRITE)
		file.store_string(data_string)
		file.close()
	load_opening_screen()

func clear():
	for child in get_children():
		child.queue_free()

func load_opening_screen():
	clear()
	var opening_screen : OpeningScreen = load(OPENING_SCREEN_PATH).instantiate()
	opening_screen.month_view_selected.connect(open_month_view)
	opening_screen.expense_category_configuration_selected.connect(open_expense_category_configuration)
	add_child(opening_screen)

func open_month_view():
	clear()
	var month_view : MonthView = load(MONTH_VIEW_PATH).instantiate()
	month_view.back_pressed.connect(load_opening_screen)
	add_child(month_view)

func open_expense_category_configuration():
	clear()
	var configuration : ExpenseCategoryConfiguration = load(EXPENSE_CATEGORY_CONFIGURATION_PATH).instantiate()
	configuration.back_pressed.connect(load_opening_screen)
	add_child(configuration)
