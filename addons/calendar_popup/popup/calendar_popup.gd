extends Panel
class_name CalendarPopup

@onready var month_reduce: Button = $VBoxContainer/MonthYear/Reduce
@onready var month_increase: Button = $VBoxContainer/MonthYear/Increase
@onready var month_select: OptionButton = $VBoxContainer/MonthYear/Month
@onready var year_box: SpinBox = $VBoxContainer/MonthYear/Year

@onready var weekdays_container : HBoxContainer = $VBoxContainer/Weekdays
@onready var days_container : GridContainer = $VBoxContainer/Days

@onready var selected_date_label : Label = $VBoxContainer/BottomRow/SelectedDate
@onready var select_button : Button =  $VBoxContainer/BottomRow/SelectButton

@onready var close_button: Button = $CloseButton

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
var selected_day = 0
var selected_year = 0
var selected_month = 0
var hovered_month = 0
var hovered_year = 0

const DATE_BUTTON_GROUP = "date_button"

signal date_selected(day: int, month: int, year: int)

func _set_current_time():
	var datetime = Time.get_datetime_dict_from_system()
	selected_month = datetime.month - 1
	selected_year = datetime.year
	selected_day = datetime.day
	hovered_month = selected_month
	hovered_year = selected_year
	month_select.select(hovered_month)
	_set_selected_label()

func _ready():
	_connect_signals()
	_generate_weekday_labels()
	_set_current_time()
	_generate_calendar()
	_set_selected_label()
	open()

func _set_selected_label():
	match (date_string_type):
		DateStringOptions.MMDDYYYY:
			selected_date_label.text = "%02d/%02d/%d" % [selected_month+1, selected_day, selected_year]
		DateStringOptions.DDMMYYYY:
			selected_date_label.text = "%02d/%02d/%d" % [selected_day, selected_month+1, selected_year]
		DateStringOptions.MonthDDYYYY:
			selected_date_label.text = "%s %02d %d" % [Calendar.MONTH_STRINGS[selected_month], selected_day, selected_year]
		DateStringOptions.DDMonthYYYY:
			selected_date_label.text = "%02d %s %d" % [selected_day, Calendar.MONTH_STRINGS[selected_month], selected_year]
		
func _generate_calendar():
	_clear_dates()
	_generate_dates(hovered_month+1, hovered_year, selected_day)

func _month_selected(idx: int) -> void:
	hovered_month = idx
	_generate_calendar()

func _clear_dates():
	for child in days_container.get_children():
		child.queue_free()

func _connect_signals():
	month_reduce.pressed.connect(change_month.bind(-1))
	month_increase.pressed.connect(change_month.bind(1))
	month_select.item_selected.connect(_month_selected)
	close_button.pressed.connect(close)
	year_box.value_changed.connect(_year_changed)
	select_button.pressed.connect(select_date)

func select_date():
	date_selected.emit(selected_day, selected_month, selected_year)
	close()

func _year_changed(new_year: int) -> void:
	hovered_year = new_year
	_generate_calendar()

func change_month(amt: int) -> void:
	hovered_month += amt
	if hovered_month < 0:
		hovered_month += Calendar.MONTHS_IN_YEAR
		hovered_year -= 1
	elif hovered_month >= Calendar.MONTHS_IN_YEAR:
		hovered_month -= Calendar.MONTHS_IN_YEAR
		hovered_year += 1
	month_select.select(hovered_month)
	_generate_calendar()
	
func close():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE*.2, .3)
	tween.tween_callback(hide)

func open():
	scale = Vector2.ONE*.2
	show()
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, .3)

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
	var in_selected_month = selected_month == hovered_month && selected_year == hovered_year
	for j in range(1,days+1):
		var new_day = Button.new()
		new_day.toggle_mode = true
		new_day.add_to_group(DATE_BUTTON_GROUP)
		new_day.pressed.connect(_select_day.bind(j))
		if in_selected_month && j == day:
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
	selected_month = hovered_month
	selected_year = hovered_year
	for button in get_tree().get_nodes_in_group(DATE_BUTTON_GROUP):
		if button.text == str(day):
			button.disabled = true
			continue
		button.button_pressed = false
		button.disabled = false
	_set_selected_label()
