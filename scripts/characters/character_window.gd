class_name CharacterWindow
extends Window

var _current_scene_node: Node2D;
var _character: Character;
var _camera: Camera2D;
var _native_hwnd: int;
var _window_helper;
var is_bottom: bool;
var _viewport_tex;
var _is_draging: bool = false;
var _drag_offset: Vector2i;
var is_focus: bool = false;

func _init(p_node: String) -> void:
	_character = load(p_node).instantiate();
	_character.window = self;
	self.size = _character.character_size;

	var WindowHelper = load("res://scripts/window/WindowHelper.cs");
	_window_helper = WindowHelper.new();
	
	# 设置窗口名用于查找
	self.title = p_node;
	self.name = p_node;
	pass

func _ready() -> void:
	_native_hwnd = DisplayServer.window_get_native_handle(DisplayServer.WINDOW_HANDLE, self.get_window_id());
	# set_bottom();
	set_hide_taskbar(true);
	set_topmost();

	self.transparent = true;
	self.unresizable = true;

	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true, self.get_window_id());

	self.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED;
	
	_current_scene_node = Node2D.new();
	_current_scene_node.name = "CharacterWindowScene";
	
	add_child(_current_scene_node);
	
	var viewport_cotainer = SubViewportContainer.new();
	viewport_cotainer.size = size;
	viewport_cotainer.stretch = true;

	_current_scene_node.add_child(viewport_cotainer);
	
	var sub_viewport = SubViewport.new();
	sub_viewport.size = self.size;
	sub_viewport.transparent_bg = true;
	
	viewport_cotainer.add_child(sub_viewport);

	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	sub_viewport.gui_embed_subwindows = false;
	sub_viewport.gui_disable_input = false;
	
	_camera = Camera2D.new()
	sub_viewport.add_child(_camera);


	var canvas_layer = CanvasLayer.new()
	sub_viewport.add_child(canvas_layer)

	canvas_layer.add_child(_character);

	# 获取中心位置
	var offset = Vector2(sub_viewport.size.x / 2 , sub_viewport.size.y / 2);
	
	# self.set_mouse_passthrough_polygon(_character.get_poly());
	_character.global_position = offset;
	
	var main_scene = get_tree().root.get_node("MainScene");
	main_scene.global_time_update.connect(_on_global_time_update);
	
	self.window_input.connect(_on_window_input);
	self.mouse_entered.connect(_on_mouse_entered);

	pass;


func _process(delta: float) -> void:
	if _is_draging and is_focus:
		var pos = DisplayServer.mouse_get_position() - _drag_offset;
		self.position = pos;
	pass;

func _on_global_time_update(p_delta: float) -> void:
	pass;

# 隐藏任务栏
func set_hide_taskbar(p_hide: bool) -> void:
	call_deferred("_set_hide_taskbar", p_hide);

func _set_hide_taskbar(p_hide: bool) -> void:
	if _window_helper == null:
		return;
	
	_window_helper.HideFromTaskbar(_native_hwnd, p_hide);

# 置顶
func set_topmost() -> void:
	call_deferred("_set_topmost");

func _set_topmost() -> void:
	if _window_helper == null:
		return;
		
	is_focus = true;
	is_bottom = false;
	_window_helper.SetWindowTopmost(_native_hwnd);

# 置底
func set_bottom() -> void:
	call_deferred("_set_bottom");


func _set_bottom() -> void:
	if _window_helper == null:
		return;
		
	is_focus = false;
	is_bottom = true;
	_window_helper.SetWindowBottom(_native_hwnd);


# 聚焦
func set_foregound() -> void:
	if _window_helper == null:
		return;
	
	is_bottom = false;
	_window_helper.SetForegroundWindow(_native_hwnd);

# 获取Rect
func get_rect() -> Rect2:
	return Rect2(DisplayServer.window_get_position(self.get_window_id()), self.size)
	
func _on_mouse_entered() -> void:
	print("_on_mouse_entered");
	is_focus = true;
	pass;

func _on_window_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				print("_on_window_input event.pressed");
				_is_draging = true;
				_drag_offset = event.position;
			else:
				_is_draging = false;
	
	pass;
