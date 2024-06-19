class_name QuickSwitchDialog extends ConfirmationDialog


signal file_selected(path: String)


@onready var search_box: LineEdit = %SearchBox
@onready var item_list: ItemList = %ItemList
@onready var preview_container: PanelContainer = %PreviewContainer
@onready var preview: CodeEdit = %Preview


var base_path: String
var path: String
var string_items: Array[WeightedText] = []


func _init() -> void:
	about_to_popup.connect(_about_to_popup)
	canceled.connect(_canceled)
	confirmed.connect(_confirmed)
	file_selected.connect(func(_path: String): hide())


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.as_text_key_label() in "ABCDEFGHIJKLMNOPQRSTUVWXYZ":
			search_box.grab_focus()


func _about_to_popup():
	item_list.clear()
	preview_container.hide()
	string_items = WeightedText.convert_array(get_paths(path))
	_set_item_list_items(string_items)
	get_ok_button().disabled = true
	await get_tree().process_frame
	search_box.grab_focus.call_deferred()


func get_paths(path: String) -> PackedStringArray:
	var arr: PackedStringArray = []
	for file in DirAccess.get_files_at(path):
		arr.append(path.path_join(file).trim_prefix(base_path))
	for dir in DirAccess.get_directories_at(path):
		arr.append_array(get_paths(path.path_join(dir)))
	
	return arr


func _canceled():
	file_selected.emit("")


func _confirmed():
	if item_list.get_selected_items().size() > 0:
		file_selected.emit(item_list.get_item_text(item_list.get_selected_items()[0]))
	else:
		file_selected.emit("")


func _on_search_box_text_changed(query: String) -> void:
	string_items.sort_custom(
			func(a: WeightedText, b: WeightedText) -> bool:
				if not a.query_text == query:
					a.query_text = query
					a.weight = _search_ranking(query, a.text)
				
				if not b.query_text == query:
					b.query_text = query
					b.weight = _search_ranking(query, b.text)
				
				return a.weight > b.weight
				)
	
	_set_item_list_items(string_items)
	if item_list.item_count > 0:
		item_list.select(0)
		_on_item_list_item_selected(0)
	item_list.get_v_scroll_bar().value = 0.0
	

func _set_item_list_items(arr: Array[WeightedText]) -> void:
	item_list.clear()
	for item in arr:
		item_list.add_item(item.text)


func _on_search_box_text_submitted(new_text: String) -> void:
	if new_text == "":
		return
	file_selected.emit(item_list.get_item_text(item_list.get_selected_items()[0]))


func _on_item_list_item_selected(index: int) -> void:
	get_ok_button().disabled = false
	var is_text: bool = item_list.get_item_text(index).get_extension() in Settings.text_file_types
	preview_container.visible = is_text
	if is_text:
		preview.text = FileAccess.get_file_as_string(base_path.path_join(item_list.get_item_text(index)))
	item_list.ensure_current_is_visible.call_deferred()


func _on_item_list_item_activated(index: int) -> void:
	file_selected.emit(item_list.get_item_text(index))


func _on_search_box_gui_input(event: InputEvent) -> void:
	if event is InputEventWithModifiers:
		if search_box.has_focus() and item_list.visible:
			if event.get_modifiers_mask() & KEY_MODIFIER_MASK:
				return
			
			if event.is_action_pressed("ui_text_caret_up"):
				if item_list.get_selected_items():
					var selected: int = item_list.get_selected_items()[0]
					item_list.select(posmod(selected - 1, item_list.item_count))
					_on_item_list_item_selected(item_list.get_selected_items()[0])
					search_box.grab_focus.call_deferred()
					set_input_as_handled()
				else:
					item_list.select(0)
			
			if event.is_action_pressed("ui_text_caret_down"):
				if item_list.get_selected_items():
					var selected: int = item_list.get_selected_items()[0]
					item_list.select(posmod(selected + 1, item_list.item_count))
					_on_item_list_item_selected(item_list.get_selected_items()[0])
					search_box.grab_focus.call_deferred()
					set_input_as_handled()
				else:
					item_list.select(0)


func _search_ranking(query: String, text: String) -> float:
	#return (text.to_lower().similarity(query.to_lower()) - 0.1 * maxf(0.0, text.find(query))) * (float(text.length()) / float(query.length()))
	text = text.to_lower()
	query = query.to_lower()
	var weight: float = 0.0
	for keyword in query.split("/", false):
		weight += text.countn(keyword) + text.similarity(keyword)
	return weight


class WeightedText extends RefCounted:
	var weight: float
	var text: String
	var query_text: String = ""
	
	func _init(_weight: float, _text: String) -> void:
		weight = _weight
		text = _text
	
	static func convert_array(array: PackedStringArray, weight: float = 0.0) -> Array[WeightedText]:
		var new_array: Array[WeightedText] = []
		new_array.resize(array.size())
		for i in array.size():
			new_array[i] = WeightedText.new(weight, array[i])
		return new_array
