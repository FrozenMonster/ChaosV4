extends RefCounted
class_name Player3CLogic
## Sacrosanct 3C Movement, Committed Dodge-Roll & Graze Siphon Logic Core (GDD #2, ADR-002 & ADR-003).
## Pure RefCounted class (~120 lines): runs on unblocked delta, zero scene dependencies.

const BalanceConfigScript = preload("res://src/core/balance_config.gd")

var pos: Vector2 = Vector2(640.0, 520.0)
var vel: Vector2 = Vector2.ZERO
var last_move_dir: Vector2 = Vector2.UP
var recoil_slide_vel: Vector2 = Vector2.ZERO
var arena_bounds: Rect2 = Rect2(80.0, 90.0, 1120.0, 560.0)

# Stat modifiers from 4-Stage Pipeline / Bucky's Exoskeleton Forge
var passive_speed_bonus: float = 0.0
var graze_radius_mult: float = 1.0
var bonus_graze_cap: int = 0
var bonus_iframe_sec: float = 0.0 # Capped at +0.06s so DODGE_DURATION (0.42s) never changes

# Dodge Roll state
var is_dodging: bool = false
var dodge_timer: float = 0.0
var dodge_dir: Vector2 = Vector2.ZERO
var roll_graze_count: int = 0


func get_effective_walk_speed() -> float:
	var mult: float = clampf(1.0 + passive_speed_bonus, 1.0, BalanceConfigScript.MAX_SPEED_MULT)
	return BalanceConfigScript.BASE_MOVE_SPEED * mult


func get_effective_iframe_end() -> float:
	return clampf(BalanceConfigScript.DODGE_IFRAME_END + bonus_iframe_sec, BalanceConfigScript.DODGE_IFRAME_END, 0.34)


func get_effective_graze_radius() -> float:
	return BalanceConfigScript.BASE_GRAZE_RADIUS * clampf(graze_radius_mult, 1.0, 1.60)


func get_max_graze_per_roll() -> int:
	return BalanceConfigScript.MAX_GRAZE_PER_ROLL + clampi(bonus_graze_cap, 0, 1)


func is_in_iframes() -> bool:
	return is_dodging and dodge_timer <= get_effective_iframe_end()


func is_in_recovery() -> bool:
	return is_dodging and dodge_timer > get_effective_iframe_end()


## computes instantaneous move speed per GDD #2 Formula 1.
func get_current_move_speed() -> float:
	if not is_dodging:
		return get_effective_walk_speed()
	var factor: float = 1.0 if dodge_timer <= get_effective_iframe_end() else BalanceConfigScript.DODGE_RECOVERY_FACTOR
	return BalanceConfigScript.DODGE_SPEED * factor


func try_start_dodge(move_input: Vector2, aim_target_pos: Vector2) -> bool:
	if is_dodging:
		return false
	is_dodging = true
	dodge_timer = 0.0
	roll_graze_count = 0
	if move_input.length_squared() > 0.01:
		dodge_dir = move_input.normalized()
		last_move_dir = dodge_dir
	else:
		var to_aim: Vector2 = aim_target_pos - pos
		dodge_dir = to_aim.normalized() if to_aim.length_squared() > 0.01 else last_move_dir
	return true


func apply_shooter_recoil_slide(aim_dir: Vector2, slide_distance_px: float) -> void:
	if is_dodging or slide_distance_px <= 0.0:
		return
	# Apply impulse over ~0.08s that decays smoothly and clamps safely against arena bounds
	recoil_slide_vel = -aim_dir.normalized() * (slide_distance_px * 12.5)


func update_3c(delta: float, move_input: Vector2, solid_barriers: Array = []) -> void:
	var clean_input: Vector2 = move_input.normalized() if move_input.length_squared() > 0.01 else Vector2.ZERO
	if clean_input.length_squared() > 0.01:
		last_move_dir = clean_input

	if is_dodging:
		dodge_timer += delta
		vel = dodge_dir * get_current_move_speed()
		if dodge_timer >= BalanceConfigScript.DODGE_DURATION:
			is_dodging = false
			dodge_timer = 0.0
	else:
		vel = clean_input * get_effective_walk_speed()

	if recoil_slide_vel.length_squared() > 1.0:
		pos += recoil_slide_vel * delta
		recoil_slide_vel = recoil_slide_vel.move_toward(Vector2.ZERO, delta * 1800.0)

	pos += vel * delta
	var r: float = BalanceConfigScript.PLAYER_HURTBOX_RADIUS
	pos.x = clampf(pos.x, arena_bounds.position.x + r, arena_bounds.end.x - r)
	pos.y = clampf(pos.y, arena_bounds.position.y + r, arena_bounds.end.y - r)

	for b in solid_barriers:
		if b.get("active", false) and float(b.get("hp", 0.0)) > 0.0:
			var rect: Rect2 = b["rect"]
			if rect.grow(r * 0.8).has_point(pos):
				var push: Vector2 = (pos - rect.get_center()).normalized()
				pos += (push if push.length_squared() > 0.01 else Vector2.DOWN) * 4.0


## Evaluates GDD #2 Formula 2 (Dodge-Roll Graze Overcharge Yield).
func try_graze_bullet(bullet: Dictionary) -> float:
	if not is_in_iframes():
		return 0.0
	if bullet.get("grazed", false):
		return 0.0
	if roll_graze_count >= get_max_graze_per_roll():
		return 0.0
	var b_pos: Vector2 = bullet.get("pos", Vector2.INF)
	if pos.distance_to(b_pos) <= get_effective_graze_radius():
		bullet["grazed"] = true
		roll_graze_count += 1
		return BalanceConfigScript.CHARGE_DODGE_GRAZE
	return 0.0
