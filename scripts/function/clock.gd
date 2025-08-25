class_name Clock

extends RefCounted

enum ClockMode {CLOCK, COUNT_DOWN};

var _mode: ClockMode = ClockMode.CLOCK;

var hour: int;
var min: int;
var sec: int;
var _is_execute: bool;

var _cd_sec: float = 0.0;
var _cd_total: float = 0.0;
var _cd_repeat: bool = false;
var _cd_callback: Callable = Callable();

var _internal_sec: float = 0.0;
# 定时器列表
var _timer_list: Array = []; 

func init_system_time() -> void:
	var now_time = Time.get_datetime_dict_from_system();
	set_time(now_time.hour, now_time.minute, now_time.second);
	
# 设置时间
func set_time(p_h: int, p_m: int, p_s: int) -> void:
	hour = p_h % 24;
	min = p_m % 60;
	sec = p_s % 60;
	_internal_sec = hour * 3600 + min * 60 + sec;
	_is_execute = true;
	
# 更新时间
func update_time(p_delta: float) -> void:
	if not _is_execute :
		return;
	
	_internal_sec += p_delta;
	_internal_sec = fposmod(_internal_sec, 86400);
	match _mode:
		ClockMode.CLOCK:
			_update_time_text(_internal_sec);
		ClockMode.COUNT_DOWN:
			_cd_sec -= p_delta;
			if _cd_sec <= 0:
				if _cd_callback.is_valid():
					_cd_callback.call();
				if _cd_repeat :
					_cd_sec = _cd_total;
				else:
					_cd_sec = 0;
					_mode = ClockMode.CLOCK;
			_update_time_text(_cd_sec);
	
# 更新时间显示
func _update_time_text(p_sec: float) -> void:
	hour = int(p_sec / 3600);
	min = int(fposmod(p_sec, 3600) / 60);
	sec = int(fposmod(p_sec, 60))

# 按时间格式设置倒计时
func set_countdown(p_h: int, p_m: int, p_s: int, p_repeat: bool = false, p_callback: Callable = Callable()):
	var total_sec = (p_h * 3600) + (p_m * 60) + p_s;
	_set_coutdown(total_sec, p_repeat, p_callback);

# 设置倒计时
func _set_coutdown(p_sec: float, p_repeat: bool, p_callback: Callable = Callable()) -> void:
	_cd_total = max(0, p_sec);
	_cd_sec = _cd_total;
	_cd_repeat = p_repeat;
	_cd_callback = p_callback;
	_mode = ClockMode.COUNT_DOWN;
	_is_execute = true;

func get_time_string() -> String:
	return "%02d:%02d:%02d" % [hour, min, sec];
	
# 获取倒计时进度
func get_coutdown_progress() -> float:
	return clamp(_cd_sec / _cd_total, 0.0, 1.0);
	
func stop_coutdown() -> void:
	_is_execute = false;
	
func start_countdown() -> void:
	_is_execute = true;

func reset_countdown() -> void:
	_set_coutdown(_cd_total, _cd_repeat, _cd_callback);
