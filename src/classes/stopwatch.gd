class_name Stopwatch extends RefCounted


enum TimeUnit {
	MICROSECONDS = 1,
	MILLISECONDS = 1000,
	SECONDS = 1000000,
}


const _UNIT_LABELS := {
	TimeUnit.MICROSECONDS: "us",
	TimeUnit.MILLISECONDS: "ms",
	TimeUnit.SECONDS: "s",
}


var timer_name: String
var unit: TimeUnit
var stop_on_disposal: bool
var _start_ticks: int


func _init(auto_start: bool = true, unit: TimeUnit = TimeUnit.MILLISECONDS, timer_name: String = "Elapsed time: ", stop_on_disposal: bool = false) -> void:
	self.unit = unit
	self.stop_on_disposal = stop_on_disposal
	self.timer_name = timer_name
	if auto_start:
		start()


func start() -> void:
	_start_ticks = Time.get_ticks_usec()


func stop(name_override: Variant = null) -> void:
	if name_override != null:
		assert(typeof(name_override) == TYPE_STRING)
	print(Util.default(name_override, timer_name), float(Time.get_ticks_usec() - _start_ticks) / unit, _UNIT_LABELS[unit])


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			if stop_on_disposal:
				print(timer_name, float(Time.get_ticks_usec() - _start_ticks) / unit, _UNIT_LABELS[unit])
