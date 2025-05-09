###################################################
# Part of Bosca Ceoil Blue                        #
# Copyright (c) 2025 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name Stepper extends HBoxContainer

signal value_changed()

var _value: int = 0
@export var value: int = 0:
	get = _get_value,
	set = _set_value
@export var min_value: int = 0
@export var max_value: int = 1
@export var step: int = 1
@export var jump_step:int = 1

var _button_holder: ButtonHolder = null
@onready var _increment_button: Button = $Increase
@onready var _decrement_button: Button = $Decrease
@onready var _label: Label = $Label


func _ready() -> void:
	_ensure_label_size()
	_update_value_label()
	_update_buttons()
	
	_button_holder = ButtonHolder.new(self, _increment_button, _decrement_button)
	_button_holder.set_press_callback(_change_value_on_hold)
	_button_holder.set_release_callback(_emit_changed_on_release)


func _process(delta: float) -> void:
	_button_holder.process(delta)


func _ensure_label_size() -> void:
	if not is_inside_tree():
		return
	
	var string_size := 0
	for num : int in [ _value, min_value, max_value ]:
		var num_size: int = ("%d" % num).length()
		if num_size > string_size:
			string_size = num_size
	
	var label_font := _label.get_theme_font("font")
	var label_font_size := _label.get_theme_font_size("font_size")
	var target_size := label_font.get_string_size("0".repeat(string_size), HORIZONTAL_ALIGNMENT_CENTER, -1, label_font_size).x
	_label.custom_minimum_size.x = target_size


func _update_value_label() -> void:
	if not is_inside_tree():
		return
	
	_label.text = "%d" % _value


func _update_buttons() -> void:
	if not is_inside_tree():
		return
	
	_increment_button.disabled = (_value == max_value)
	_decrement_button.disabled = (_value == min_value)


func _get_value() -> int:
	return _value


func _set_value(next_value: int) -> void:
	_set_value_silent(next_value)
	_update_buttons()


func _set_value_silent(next_value: int) -> void:
	if _value == next_value:
		return
	
	_value = next_value
	_update_value_label()


func _change_value_on_hold(hold_button: Button) -> void:
	var delta_sign := 0
	if hold_button == _increment_button:
		delta_sign = 1
	elif hold_button == _decrement_button:
		delta_sign = -1
	
	if delta_sign == 0:
		return
		
	# Use larger step on shift holded, maybe use input map?
	var is_jump = Input.is_key_label_pressed(KEY_SHIFT)
	var _rel_step :int =  step if not is_jump else jump_step
	var raw_value := _value + delta_sign * _rel_step
		
	# Round to the closest step value, then clamp into the limit.
	@warning_ignore("integer_division")
	var next_value := clampi((raw_value / _rel_step) * _rel_step, min_value, max_value)
	_set_value_silent(next_value)


func _emit_changed_on_release(_hold_button: Button) -> void:
	_update_buttons()
	value_changed.emit()
