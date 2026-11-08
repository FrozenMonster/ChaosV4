extends RefCounted
class_name StatPipeline
## 4-Stage Deterministic Commutative Stat Pipeline with NaN/Inf Fault Isolation (GDD #5 & ADR-003).
## Pure RefCounted class (~85 lines): equipping [A,B,C] vs [C,A,B] produces identical results.

const BalanceConfigScript = preload("res://src/core/balance_config.gd")

const STAT_SAFETY_BOUNDS: Dictionary = {
	"move_speed": Vector2(BalanceConfigScript.BASE_MOVE_SPEED, BalanceConfigScript.BASE_MOVE_SPEED * BalanceConfigScript.MAX_SPEED_MULT),
	"fire_interval": Vector2(0.04, 3.0),
	"sweet_spot_end": Vector2(0.25, 0.90),
	"max_overcharge": Vector2(65.0, 150.0),
	"dodge_duration": Vector2(BalanceConfigScript.DODGE_DURATION, BalanceConfigScript.DODGE_DURATION), # 100% locked!
	"dodge_iframe_end": Vector2(BalanceConfigScript.DODGE_IFRAME_END, 0.34),
	"graze_radius": Vector2(BalanceConfigScript.BASE_GRAZE_RADIUS, BalanceConfigScript.BASE_GRAZE_RADIUS * 1.60),
	"damage": Vector2(1.0, 2000.0)
}


## Evaluates GDD #5 Formula 1:
## evaluate_stat(S) = clamp((base + sum_flat) * max(0.10, 1.0 + sum_pct) * prod_mult, min_floor, max_ceil)
static func evaluate_stat(stat_name: String, base_value: float, modifiers: Array[Dictionary]) -> float:
	var sum_flat: float = 0.0
	var sum_pct: float = 0.0
	var prod_mult: float = 1.0

	for mod in modifiers:
		if str(mod.get("stat", "")) != stat_name:
			continue
		var val: float = float(mod.get("value", 0.0))
		# ADR-003 Per-Item Fault Isolation: ignore NaN or Inf from buggy custom/MOD scripts
		if is_nan(val) or is_inf(val):
			continue
		var stage: String = str(mod.get("stage", "pct_add"))
		match stage:
			"flat":
				sum_flat += val
			"pct_add":
				sum_pct += val
			"indep_mult":
				if val > 0.0:
					prod_mult *= val

	var raw_result: float = (base_value + sum_flat) * maxf(0.10, 1.0 + sum_pct) * prod_mult
	if is_nan(raw_result) or is_inf(raw_result):
		raw_result = base_value

	if STAT_SAFETY_BOUNDS.has(stat_name):
		var bounds: Vector2 = STAT_SAFETY_BOUNDS[stat_name]
		return clampf(raw_result, bounds.x, bounds.y)
	return raw_result
