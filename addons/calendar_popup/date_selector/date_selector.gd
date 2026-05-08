extends Panel
class_name DateSelector

@onready var month_reduce: Button = $VBoxContainer/MonthYear/Reduce
@onready var month_increase: Button = $VBoxContainer/MonthYear/Increase
@onready var month_select: OptionButton = $VBoxContainer/MonthYear/Month
@onready var year_box: SpinBox = $VBoxContainer/MonthYear/Year

@onready var weekdays_container : HBoxContainer = $VBoxContainer/Weekdays
@onready var days_container : GridContainer = $VBoxContainer/Days

@export var week_start_offset : Calendar.Weekdays = Calendar.Weekdays.Sunday
enum StringOptions {
	Full = 0,
	Triple = 1,
	Single = 2
}
@export var day_string_type : StringOptions = StringOptions.Triple
enum DateStringOptions {
	MMDDYYYY = 0,
	DDMMYYYY = 1,
	MonthDDYYYY = 2,
	DDMonthYYYY = 3
}
@export var date_string_type : DateStringOptions = DateStringOptions.MMDDYYYY
var selected_day = 1
var selected_year = 0
var selected_month = 0

const DATE_BUTTON_GROUP = "date_button"

signal date_changed(day: int, month: int, year: int)

func _set_current_time():
	var datetime = Time.get_datetime_dict_from_system()
	selected_month = datetime.month - 1
	selected_year = datetime.year
	selected_day = datetime.day
	month_select.select(selected_month)
	date_changed.emit(selected_day, selected_month, selected_year)
	print("emit date changed")

func _ready():
	_connect_signals()
	_generate_weekday_labels()
	_set_current_time()
	_generate_calendar()


func _generate_calendar():
	_clear_dates()
	_generate_dates(selected_month+1, selected_year, selected_day)

func _month_selected(idx: int) -> void:
	selected_month = idx
	_generate_calendar()

func _clear_dates():
	for child in days_container.get_children():
		child.queue_free()

func _connect_signals():
	month_reduce.pressed.connect(change_month.bind(-1))
	month_increase.pressed.connect(change_month.bind(1))
	month_select.item_selected.connect(_month_selected)
	year_box.value_changed.connect(_year_changed)

func _year_changed(new_year: int) -> void:
	selected_year = new_year
	selected_day = 1
	_generate_calendar()
	date_changed.emit(selected_day, selected_month, selected_year)

func change_month(amt: int) -> void:
	selected_month += amt
	selected_day = 1
	if selected_month < 0:
		selected_month += Calendar.MONTHS_IN_YEAR
		selected_year -= 1
	elif selected_month >= Calendar.MONTHS_IN_YEAR:
		selected_month -= Calendar.MONTHS_IN_YEAR
		selected_year += 1
	month_select.select(selected_month)
	_generate_calendar()
	
func _generate_weekday_labels():
	for i in range(Calendar.DAYS_IN_WEEK):
		var day_idx = (i + week_start_offset) % Calendar.DAYS_IN_WEEK
		var day = Label.new()
		match (day_string_type):
			StringOptions.Full:
				day.text = Calendar.WEEKDAY_STRINGS[day_idx]
			StringOptions.Triple:
				day.text = Calendar.WEEKDAY_STRINGS[day_idx].substr(0,3)
			StringOptions.Single:
				day.text = Calendar.WEEKDAY_STRINGS[day_idx].substr(0,1)
		center_expand_label(day)
		weekdays_container.add_child(day)

func expand_control(control: Control) -> void:
	control.set_h_size_flags(SIZE_EXPAND_FILL)
	control.set_v_size_flags(SIZE_EXPAND_FILL)

func center_expand_label(label: Label) -> void:
	label.set_h_size_flags(SIZE_EXPAND_FILL)
	label.set_v_size_flags(SIZE_EXPAND_FILL)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment =  VERTICAL_ALIGNMENT_CENTER

func _get_days_in_month(target_month: int, target_year: int) -> int:
	var next_month = target_month + 1 if target_month < 12 else 1
	var next_year = target_year if target_month < 12 else target_year + 1
	var first_day_next_month = Time.get_unix_time_from_datetime_dict({
		"year": next_year, "month": next_month, "day": 1
	})
	var last_day_of_current_month = Time.get_datetime_dict_from_unix_time(first_day_next_month - 86400)
	return last_day_of_current_month.day

func _generate_dates(month, year, day=0):
	var days = Calendar.get_days_in_month(month, year)
	var precount = (Calendar.get_month_start_day(month, year) - week_start_offset)
	if precount < 0:
		precount += Calendar.DAYS_IN_WEEK
	if precount != 0:
		var previous_month = month - 1
		var previous_year = year
		if previous_month < 0:
			previous_year -= 1
		var previous_month_days = _get_days_in_month(previous_month, previous_year)
		var previous_month_day_offset = precount - 1
		while previous_month_day_offset >= 0:
			var new_day = Label.new()
			new_day.text = str(previous_month_days - previous_month_day_offset)
			center_expand_label(new_day)
			days_container.add_child(new_day)
			previous_month_day_offset -= 1
	for j in range(1,days+1):
		var new_day = Button.new()
		new_day.toggle_mode = true
		new_day.add_to_group(DATE_BUTTON_GROUP)
		new_day.pressed.connect(_select_day.bind(j))
		if j == day:
			new_day.button_pressed = true
			new_day.disabled = true
		expand_control(new_day)
		new_day.text = str(j)
		days_container.add_child(new_day)
	for x in range((Calendar.DAYS_IN_WEEK*6)-(precount+days)):
		var new_day = Label.new()
		new_day.text = str(x+1)
		center_expand_label(new_day)
		days_container.add_child(new_day)
		
		
func _select_day(day: int):
	selected_day = day
	for button in get_tree().get_nodes_in_group(DATE_BUTTON_GROUP):
		if button.text == str(day):
			button.disabled = true
			continue
		button.button_pressed = false
		button.disabled = false
	date_changed.emit(selected_day, selected_month, selected_year)
	
	
	
