extends RefCounted
class_name CombatEventBus
## Decoupled 4-Stage Priority Event Bus with Per-Frame Recursion Guard & F3 Trace Log (ADR-001).
## Pure RefCounted core (~115 lines): 100% testable in <1ms without scene tree.

const BalanceConfigScript = preload("res://src/core/balance_config.gd")

const STAGE_MATH_MUTATORS: int = 100
const STAGE_RELIC_PROCS: int = 200
const STAGE_PHYSICS_CLEARS: int = 300
const STAGE_PRESENTATION: int = 400
const TRACE_RING_CAPACITY: int = 64

var _listeners: Dictionary = {} # signal_name -> Array[Dictionary {id, callable, priority}]
var _trace_ring: Array[Dictionary] = []
var _trace_write_idx: int = 0

var current_recursion_depth: int = 0
var frame_proc_counter: int = 0
var current_frame_number: int = 0
var _cooldown_timestamps: Dictionary = {} # key -> float


func begin_frame(frame_num: int = -1) -> void:
	frame_proc_counter = 0
	current_recursion_depth = 0
	if frame_num >= 0:
		current_frame_number = frame_num
	else:
		current_frame_number += 1


## Registers a listener sorted deterministically by stage priority (100 -> 200 -> 300 -> 400).
func subscribe(signal_name: StringName, listener_id: StringName, callback: Callable, priority: int = STAGE_RELIC_PROCS) -> void:
	if not _listeners.has(signal_name):
		_listeners[signal_name] = []
	var list: Array = _listeners[signal_name]
	for i in range(list.size() - 1, -1, -1):
		if list[i]["id"] == listener_id:
			list.remove_at(i)
	list.append({"id": listener_id, "callable": callback, "priority": priority})
	list.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a["priority"]) < int(b["priority"])
	)


func unsubscribe(signal_name: StringName, listener_id: StringName) -> void:
	if not _listeners.has(signal_name):
		return
	var list: Array = _listeners[signal_name]
	for i in range(list.size() - 1, -1, -1):
		if list[i]["id"] == listener_id:
			list.remove_at(i)


## Returns remaining secondary proc allowance under the GDD #1 formula.
func get_effective_proc_allowance() -> int:
	var rem: int = clampi(BalanceConfigScript.MAX_PROCS_PER_FRAME - frame_proc_counter, 0, BalanceConfigScript.MAX_PROCS_PER_FRAME)
	var depth_ok: int = 1 if current_recursion_depth < BalanceConfigScript.MAX_RECURSION_DEPTH else 0
	return rem * depth_ok


## Evaluates GDD #1 Per-Signal Internal Cooldown Gate (prevents 1 barrel on 4 enemies from paying 4x).
func can_trigger_with_cooldown(source_key: StringName, current_time: float, cooldown_sec: float = 0.15) -> bool:
	var last_t: float = float(_cooldown_timestamps.get(source_key, -999.0))
	if (current_time - last_t) >= cooldown_sec:
		_cooldown_timestamps[source_key] = current_time
		return true
	return false


## Emits a combat event across Stages 100 -> 200 -> 300 -> 400 over a safe snapshot copy.
func emit_combat_event(signal_name: StringName, payload: Dictionary = {}, is_secondary_proc: bool = false) -> int:
	if is_secondary_proc:
		if get_effective_proc_allowance() <= 0:
			return 0
		current_recursion_depth += 1

	_record_trace(signal_name, payload, current_recursion_depth)
	var executed_count: int = 0

	if _listeners.has(signal_name):
		var snapshot: Array = (_listeners[signal_name] as Array).duplicate()
		for entry in snapshot:
			var prio: int = int(entry["priority"])
			# Stage 200 secondary relic procs obey recursion depth & 32 procs/frame cap
			if prio == STAGE_RELIC_PROCS:
				if current_recursion_depth >= BalanceConfigScript.MAX_RECURSION_DEPTH:
					continue
				if frame_proc_counter >= BalanceConfigScript.MAX_PROCS_PER_FRAME:
					continue
				frame_proc_counter += 1
			var cb: Callable = entry["callable"]
			if cb.is_valid():
				cb.call(payload)
				executed_count += 1

	if is_secondary_proc:
		current_recursion_depth = maxi(0, current_recursion_depth - 1)
	return executed_count


func _record_trace(signal_name: StringName, payload: Dictionary, depth: int) -> void:
	var item := {
		"frame": current_frame_number,
		"signal": signal_name,
		"depth": depth,
		"procs": frame_proc_counter,
		"source": payload.get("source_id", &"player")
	}
	if _trace_ring.size() < TRACE_RING_CAPACITY:
		_trace_ring.append(item)
	else:
		_trace_ring[_trace_write_idx] = item
		_trace_write_idx = (_trace_write_idx + 1) % TRACE_RING_CAPACITY


func get_trace_log() -> Array[Dictionary]:
	return _trace_ring.duplicate()
