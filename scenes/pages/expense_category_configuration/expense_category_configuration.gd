extends Control
class_name ExpenseCategoryConfiguration

@onready var tree : CategoryTree = $VBoxContainer/HBoxContainer/Tree
@onready var back_button : Button = $VBoxContainer/TopRow/BackButton
@onready var selected_name_label : Label = $VBoxContainer/HBoxContainer/HBoxContainer/VBoxContainer/Selected/Name
@onready var subcategory_name_edit : LineEdit = $VBoxContainer/HBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/CategoryName
signal back_pressed

func _ready():
	back_button.pressed.connect(back_pressed.emit)

func _on_tree_item_selected():
	var tween = create_tween()
	var selected = tree.get_selected()
	selected_name_label.text = selected.get_text(0)
	tween.tween_property(selected_name_label, "modulate", Color.BLUE, .25)
	tween.tween_property(selected_name_label, "modulate", Color.WHITE, .25)
	


func _on_create_pressed():
	var selected = tree.get_selected()
	if selected == null:
		return
	if selected.get_metadata(0) == null:
		var subcategory_name = subcategory_name_edit.text.strip_edges()
		if subcategory_name != "":
			var subcategory = Category.new()
			subcategory.name = subcategory_name
			tree.expense_configuration.categories.append(subcategory)
			tree.expense_configuration.name_sort_subcategories()
			reset()
	else:
		var subcategory_name = subcategory_name_edit.text.strip_edges()
		if subcategory_name != "":
			var subcategory = Category.new()
			subcategory.name = subcategory_name
			var category : Category = selected.get_metadata(0)
			category.subcategories.append(subcategory)
			category.name_sort_subcategories()
			reset()

func reset():
	tree.save_configuration()
	tree.reset_tree()
	subcategory_name_edit.text = ""
	selected_name_label.text = ""

func _on_delete_pressed():
	var selected = tree.get_selected()
	if selected == null:
		return
	if selected.get_metadata(0) == null:
		return
	var category = selected.get_metadata(0)
	var parent = selected.get_parent().get_metadata(0)
	if parent == null:
		#is a mainline category
		tree.expense_configuration.delete(category)
	else:
		#is a sub categroy
		parent.delete(category)
	reset()
	
