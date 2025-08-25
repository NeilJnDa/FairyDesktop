extends Node2D

signal global_time_update(delta);

# 窗口管理
var _window_map: Dictionary = {};
var _last_time_usec: float = 0;
var _native_hwnd: int;
var screen_size: Vector2i;
var _window_helper;

func _ready() -> void:

	_last_time_usec = Time.get_ticks_usec();	
	var WindowHelper = load("res://scripts/window/WindowHelper.cs");
	
	_window_helper=  WindowHelper.new();
	
	var viewport = get_viewport();
	viewport.transparent_bg = true;
	viewport.gui_embed_subwindows = false;
	
	var window = get_window();
	window.borderless = true;

	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED);

	window.always_on_top = true;

	_native_hwnd = DisplayServer.window_get_native_handle(DisplayServer.WINDOW_HANDLE, window.get_window_id());
	_window_helper.HideFromTaskbar(_native_hwnd, true);
	_window_helper.SetWindowMousePassthrough(_native_hwnd);

	screen_size = DisplayServer.screen_get_size();
	
	var characterWindow = create_character_window("res://scenes/prefab/character.tscn");
	characterWindow.position = Vector2i(screen_size.x / 2, screen_size.y / 2);

	pass;

func _process(delta: float) -> void:
	var current_usec = Time.get_ticks_usec();
	var elapsed_sec = (current_usec - _last_time_usec) / 1000000.0
	_last_time_usec = current_usec;
	
	emit_signal("global_time_update", elapsed_sec);
	

	# 窗口未聚焦时无法检测输入事件 需要手动聚焦
	var mousePos = DisplayServer.mouse_get_position();
	var window = get_character_window("res://scenes/prefab/character.tscn");
	if window is CharacterWindow:
		if window.get_rect().has_point(mousePos) and not window.is_bottom:
			window.grab_focus();
			

func _input(event: InputEvent) -> void:
	print("_input");
	pass;

# 创建窗口
func create_character_window(p_name: String) -> Window:
	if _window_map.has(p_name):
		return _window_map[p_name];
	
	var window = CharacterWindow.new(p_name);
	_window_map[p_name] = window;
	
	add_child(window);	
	window.show();
	return window;

func get_character_window(p_name: String) -> Window:
	if not _window_map.has(p_name):
		return null;

	return _window_map[p_name];
