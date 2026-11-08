extends RefCounted
class_name AudioJuiceLogic
## 4-Bus Sidechain Ducking (-4.0 dB), Streak Pitch Ladders & Capped 18px Camera Shake (GDD #10 & ADR-006).
## Pure RefCounted core (~90 lines): drives audio mix state and procedural visual juice math.

const BalanceConfigScript = preload("res://src/core/balance_config.gd")

const DUCKING_DB: float = -4.0
const DUCKING_DURATION_SEC: float = 0.20
const MIN_PITCH_FLOOR: float = 0.85
const MAX_PITCH_CEILING: float = 1.40

var ducking_timer: float = 0.0
var directional_kick_px: float = 0.0
var last_kick_aim_dir: Vector2 = Vector2.RIGHT
var trauma_shake_px: float = 0.0
var user_screen_shake_setting: float = 1.0


func trigger_critical_cue_ducking() -> void:
	ducking_timer = DUCKING_DURATION_SEC


func get_secondary_bus_ducking_db() -> float:
	return DUCKING_DB if ducking_timer > 0.0 else 0.0


func tick_audio_and_juice(delta: float) -> void:
	if ducking_timer > 0.0:
		ducking_timer = maxf(0.0, ducking_timer - delta)
	if directional_kick_px > 0.0:
		directional_kick_px = maxf(0.0, directional_kick_px - delta * 35.0)
	if trauma_shake_px > 0.0:
		trauma_shake_px = maxf(0.0, trauma_shake_px - delta * 28.0)


## Computes GDD #10 Formula 1 (Streak Pitch-Escalation Multiplier).
static func compute_streak_pitch(streak_count: int, pitch_step_per_stack: float, base_pitch: float = 1.00) -> float:
	var raw: float = base_pitch + pitch_step_per_stack * float(maxi(1, streak_count) - 1)
	return clampf(raw, MIN_PITCH_FLOOR, MAX_PITCH_CEILING)


func apply_camera_impulse(aim_dir: Vector2, kick_px: float, trauma_px: float) -> void:
	if aim_dir.length_squared() > 0.01:
		last_kick_aim_dir = aim_dir.normalized()
	directional_kick_px = maxf(directional_kick_px, kick_px)
	trauma_shake_px = maxf(trauma_shake_px, trauma_px)


## Computes GDD #10 Formula 2 (Combined Directional Camera Kick & Trauma Shake Offset, hard-capped at 18.0 px).
func compute_final_camera_offset(jitter_vec: Vector2 = Vector2.ZERO) -> Vector2:
	var raw_ofs: Vector2 = (-last_kick_aim_dir * directional_kick_px) + jitter_vec * trauma_shake_px
	return raw_ofs.limit_length(BalanceConfigScript.MAX_SHAKE_OFFSET) * clampf(user_screen_shake_setting, 0.0, 1.0)
