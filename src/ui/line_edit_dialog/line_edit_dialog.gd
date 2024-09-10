@tool
class_name LineEditDialog extends ConfirmationDialog


signal finished(text: String)


var line_edit: LineEdit
var container: VBoxContainer
var custom_ui: Dictionary[String, Control]


@export var text: String = "":
	set(value):
		if line_edit:
			line_edit.text = value
		text = value
	get:
		return text
@export var placeholder_text: String = "":
	set(value):
		if line_edit:
			line_edit.placeholder_text = placeholder_text
		placeholder_text = value
	get:
		return placeholder_text
@export var select_all: bool = true
@export var disallowed_chars: String = ""
var previous_text: String


func _init() -> void:
	line_edit = LineEdit.new()
	line_edit.text_changed.connect(
		func(new_text: String):
			if disallowed_chars:
				var pos = _check_text(new_text, disallowed_chars)
				if not pos == -1:
					line_edit.text = previous_text
					line_edit.caret_column = pos
			previous_text = line_edit.text
			)
	line_edit.text_submitted.connect(func(new_text: String): finished.emit(new_text))
	line_edit.select_all_on_focus = true

	container = VBoxContainer.new()
	container.set_anchors_preset(Control.PRESET_FULL_RECT)

	add_child(container)
	container.add_child(line_edit)

	self.canceled.connect(func(): finished.emit(""))
	self.confirmed.connect(func(): finished.emit(line_edit.text))
	self.about_to_popup.connect((
		func():
			line_edit.grab_focus()
			if select_all:
				line_edit.select_all()
			previous_text = line_edit.text
			size.y = 0
			).call_deferred)


func add_custom_ui(ui: Control, identifier: String) -> void:
	container.add_child(ui)
	custom_ui[identifier] = ui


## r':/\?*"|%<>' for filenames
func _check_text(bad_text: String, pattern: String) -> int:
	for pattern_char in pattern:
		var pos = bad_text.find(pattern_char)
		if not pos == -1:
			return pos
	return -1
