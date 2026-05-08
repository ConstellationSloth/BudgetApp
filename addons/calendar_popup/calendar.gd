extends Object
class_name Calendar

const MONTH_STRINGS : Array[String] = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
const WEEKDAY_STRINGS : Array[String] = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
enum Weekdays {
	Sunday = 0,
	Monday = 1,
	Tuesday = 2,
	Wednesday = 3,
	Thursday = 4,
	Friday = 5,
	Saturday = 6
}
const DAYS_IN_WEEK = 7
const MONTHS_IN_YEAR = 12
enum Months {
	January = 0,
	February = 1,
	March = 2,
	April = 3,
	May = 4,
	June = 5,
	July = 6,
	August = 7,
	September = 8,
	October = 9,
	November = 10,
	December = 11
}

static func get_days_in_month(target_month: int, target_year: int) -> int:
	var next_month = target_month + 1 if target_month < 12 else 1
	var next_year = target_year if target_month < 12 else target_year + 1
	var first_day_next_month = Time.get_unix_time_from_datetime_dict({
		"year": next_year, "month": next_month, "day": 1
	})
	var last_day_of_current_month = Time.get_datetime_dict_from_unix_time(first_day_next_month - 86400)
	return last_day_of_current_month.day

static func get_month_start_day(target_month: int, target_year: int) -> int:
	return Time.get_datetime_dict_from_unix_time(Time.get_unix_time_from_datetime_dict({
		"year": target_year, "month": target_month, "day": 1
	})).weekday

static func get_day_letters(day: int) -> String:
	if day > 3 and day < 21:
		return "th"
	var ones_digit = day % 10
	match (ones_digit):
		1:
			return "st"
		2:
			return "nd"
		3:
			return "rd"
		_:
			return "th"
