class_name Character
extends SpineSprite

var velocity := Vector2.ZERO;
var character_size: Vector2 = Vector2(400, 400);
var _window_position_offset = Vector2i(character_size.x / 2, character_size.y / 2);
var _root_bone: SpineBone;
var _skeleton: SpineSkeleton;
var _poly: Polygon2D;
var window: CharacterWindow;
var _time_label;
var _clock: Clock;

func _init() -> void:
	pass;
	
func _ready() -> void:
	var skin = self.new_skin("Custom");
	_skeleton = self.get_skeleton();
	var data = _skeleton.get_data();
	skin.add_skin(data.find_skin("Black"));
	
	_root_bone = _skeleton.get_root_bone();
	
	_skeleton.set_skin(skin);
	_skeleton.set_slots_to_setup_pose();
	var state = self.get_animation_state();
	state.set_animation("Snatch", true, 0);

	get_node("Panel/HBoxContainer/BtnStart").pressed.connect(_on_button_start_pressed);
	get_node("Panel/HBoxContainer/BtnStop").pressed.connect(_on_button_stop_pressed);
	
	_time_label = get_node("Panel/Label");
	
	var main_scene = get_tree().root.get_node("MainScene");
	main_scene.global_time_update.connect(_on_global_time_update);
	self
	
	_clock = Clock.new();
	_clock.init_system_time();

func _process(delta: float) -> void:
	_time_label.text = "%02d:%02d:%02d" % [_clock.hour, _clock.min, _clock.sec];
	

func _input(event: InputEvent) -> void:
	pass;


func set_window_position(pos: Vector2i) -> void:
	window.position = pos - _window_position_offset;

func _on_global_time_update(p_delta) -> void:
	_clock.update_time(p_delta);
	pass;

func get_poly() -> PackedVector2Array:
	return _poly.polygon;
	
func _on_button_start_pressed() -> void:
	window.set_bottom();
	print("_on_button_start_pressed");
	_clock.set_countdown(0, 0, 10, false, _on_time_out);

func _on_time_out() -> void:
	print("_on_time_out");
	window.set_topmost();
	var screen_size = DisplayServer.screen_get_size(DisplayServer.window_get_current_screen());
	set_window_position(Vector2i(screen_size.x / 2, screen_size.y));

func _on_button_stop_pressed() -> void:
	print("_on_button_stop_pressed");
	_clock.stop_coutdown();
