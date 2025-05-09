###################################################
# Part of Bosca Ceoil Blue                        #
# Copyright (c) 2025 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name NoteMapGutter extends Control

signal note_preview_requested(row_index: int)

var note_rows: Array[NoteMap.NoteRow] = []
var _hovered_row: int = -1


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		
		if mb.pressed && mb.button_index == MOUSE_BUTTON_LEFT:
			if _hovered_row >= 0 && _hovered_row < note_rows.size():
				note_preview_requested.emit(_hovered_row)


func _physics_process(_delta: float) -> void:
	_update_row_cursor()


func _draw() -> void:
	var available_rect: Rect2 = get_available_rect()
	
	# Draw background.
	var gutter_color := get_theme_color("gutter_color", "NoteMap")
	
	draw_rect(available_rect, gutter_color)
	
	# Draw keyboard
	
	var note_height := get_theme_constant("note_height", "NoteMap")
	_draw_keyboard(available_rect, note_height)
	
	# Draw note labels.
	
	var hover_color := get_theme_color("gutter_hover_color", "NoteMap")
		
	var font := get_theme_default_font()
	var font_size := get_theme_default_font_size()
	var font_color := get_theme_color("font_color", "Label")
	var shadow_color := get_theme_color("shadow_color", "Label")
	var shadow_size := Vector2(get_theme_constant("shadow_offset_x", "Label"), get_theme_constant("shadow_offset_y", "Label"))
	
	var i := 0
	for note in note_rows:
		var _hover_offset = Vector2.ZERO # small enhance on hover
		if i == _hovered_row:
			var cursor_size := Vector2(available_rect.size.x, note_height)
			var cursor_position := note.grid_position - cursor_size
			draw_rect(Rect2(cursor_position, cursor_size), hover_color)
			_hover_offset += Vector2(6,0)
			
		var string_position := note.label_position + Vector2(8, 0)
		var shadow_position := string_position + shadow_size
		
		draw_string(font, shadow_position+_hover_offset, note.label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, shadow_color)
		draw_string(font, string_position+_hover_offset, note.label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, font_color)
		
		i += 1

func _draw_keyboard(available_rect:Rect2, note_height:float):
	var _opc = 0.3
	var bkc = Color(Color.BLACK, _opc)
	var wkc = Color(Color.WHITE, _opc)
	for note in note_rows:
		var cursor_size := Vector2(available_rect.size.x, note_height)
		var rect = Rect2(note.grid_position-cursor_size, cursor_size)
		if Note.is_note_sharp(note.note_index) :
			var b_key = rect.grow_individual(0, -cursor_size.y*0.1, -cursor_size.x*0.2, -cursor_size.y*0.1)
			draw_rect(b_key, bkc)
		else:
			var w_key = rect.grow_individual(0, -cursor_size.y*0.05, -cursor_size.x*0.1, -cursor_size.y*0.05)
			draw_rect(w_key, wkc)



func get_available_rect() -> Rect2:
	var available_rect := Rect2(Vector2.ZERO, size)
	if not is_inside_tree():
		return available_rect
	
	return available_rect


# Hover and interactions.

func _get_cell_at_cursor() -> Vector2i:
	var available_rect: Rect2 = get_available_rect()
	var note_height := get_theme_constant("note_height", "NoteMap")
	
	var mouse_position := get_local_mouse_position()
	if not available_rect.has_point(mouse_position):
		return Vector2i(-1, -1)
	
	var mouse_normalized := mouse_position - available_rect.position
	var cell_indexed := Vector2i(0, 0)
	cell_indexed.y = clampi(floori((available_rect.size.y - mouse_normalized.y) / note_height), 0, note_rows.size() - 1)
	return cell_indexed


func _update_row_cursor() -> void:
	if Engine.is_editor_hint():
		return
	
	var row_indexed := _get_cell_at_cursor()
	if row_indexed.y != _hovered_row:
		_hovered_row = row_indexed.y
		queue_redraw()
