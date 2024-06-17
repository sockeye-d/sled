class_name FindBox extends LowerPanelContainer


enum Mode {
	FIND,
	REPLACE,
}


signal pattern_changed(pattern: String, use_regex: bool, case_insensitive: bool)
signal select_all_occurrences_requested()
signal replace_all_occurrences_requested(with_what: String)
signal go_to_previous_requested()
signal go_to_next_requested()
signal replace_requested(with_what: String)


@onready var pattern_line_edit: LineEdit = %PatternLineEdit
@onready var replacement_line_edit: LineEdit = %ReplacementLineEdit
@onready var select_all_occurrences_button: Button = %SelectAllOccurrencesButton
@onready var replace_all_occurrences_button: Button = %ReplaceAllOccurrencesButton
@onready var previous_match_button: Button = %PreviousMatchButton
@onready var match_count_label: Label = %MatchCountLabel
@onready var next_match_button: Button = %NextMatchButton
@onready var replace_button: Button = %ReplaceButton
@onready var case_insensitive_toggle: CheckBox = %CaseInsensitiveToggle
@onready var regex_toggle: CheckBox = %RegExToggle
@onready var replace_toggle: CheckBox = %ReplaceToggle
@onready var escape_sequences_toggle: CheckBox = %EscapeSequencesToggle


var pattern: String:
	get:
		if escape_sequences_toggle.button_pressed:
			return pattern_line_edit.text.c_unescape()
		else:
			return pattern_line_edit.text
var replacement: String:
	get:
		if escape_sequences_toggle.button_pressed:
			return replacement_line_edit.text.c_unescape()
		else:
			return replacement_line_edit.text
var use_regex: bool:
	get:
		return regex_toggle.button_pressed
var case_insensitive: bool:
	get:
		return case_insensitive_toggle.button_pressed
var in_replace_mode: bool:
	get:
		return replace_toggle.button_pressed


func _ready() -> void:
	switch_modes(Mode.REPLACE if replace_toggle.button_pressed else Mode.FIND)
	
	replace_toggle.toggled.connect(func(state: bool):
		switch_modes(Mode.REPLACE if state else Mode.FIND)
	)
	
	pattern_line_edit.text_changed.connect(_emit_changed)
	regex_toggle.toggled.connect(_emit_changed)
	case_insensitive_toggle.toggled.connect(_emit_changed)
	
	select_all_occurrences_button.pressed.connect(func():
		select_all_occurrences_requested.emit()
	)
	
	replace_all_occurrences_button.pressed.connect(func():
		replace_all_occurrences_requested.emit(replacement)
	)
	
	previous_match_button.pressed.connect(func():
		go_to_previous_requested.emit()
	)
	
	next_match_button.pressed.connect(func():
		go_to_next_requested.emit()
	)
	
	replace_button.pressed.connect(func():
		replace_requested.emit(replacement)
	)
	
	pattern_line_edit.gui_input.connect(_le_gui_input)
	replacement_line_edit.gui_input.connect(_le_gui_input)
	


func switch_modes(mode: Mode = Mode.FIND) -> void:
	NodeUtil.foreach_child(self,
		func(child: Control):
			if not child.is_in_group(&"find") and not child.is_in_group(&"replace"):
				return
			child.visible = (child.is_in_group(&"find") and mode == Mode.FIND) or (child.is_in_group(&"replace") and mode == Mode.REPLACE)
	)


func set_match_count(count: int) -> void:
	previous_match_button.disabled = count == 0
	next_match_button.disabled = count == 0
	replace_button.disabled = count == 0
	select_all_occurrences_button.disabled = count == 0
	replace_all_occurrences_button.disabled = count == 0
	if count:
		match_count_label.remove_theme_color_override(&"font_color")
	else:
		match_count_label.add_theme_color_override(&"font_color", EditorThemeManager.theme.get_color(&"font_color", &"Label").lerp(Color.RED, 0.3))
	match_count_label.text = str(count)


func set_invalid_pattern(is_invalid: bool) -> void:
	if is_invalid:
		pattern_line_edit.add_theme_color_override(&"font_color", EditorThemeManager.theme.get_color(&"font_color", &"LineEdit").lerp(Color.RED, 0.3))
	else:
		pattern_line_edit.remove_theme_color_override(&"font_color")


func show_with_focus() -> void:
	show()
	pattern_line_edit.grab_focus()


func _emit_changed(_arg) -> void:
	pattern_changed.emit(pattern, regex_toggle.button_pressed, case_insensitive_toggle.button_pressed)


func _on_close_button_pressed() -> void:
	hide()


func _on_text_submitted(new_text: String) -> void:
	if in_replace_mode:
		replace_requested.emit(replacement)
	else:
		go_to_next_requested.emit()


func _le_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape", false, true):
		hide()
