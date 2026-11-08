extends RefCounted
class_name OverchargeEngineLogic
## Calibrated 72-100⚡ Single-Room Overcharge Ledger & RMB Heavy Spender Engine (GDD #4 & ADR-003/006).
## Enforces zero out-of-combat farming (room_cleared == false gate) and 45/65/90⚡ Heavy costs (~115 lines).

const BalanceConfigScript = preload("res://src/core/balance_config.gd")

var overcharge: float = 0.0
var max_overcharge: float = BalanceConfigScript.BASE_MAX_OVERCHARGE
var heavy_cd_timer: float = 0.0
var room_cleared: bool = false
var room_overcharge_accumulated: float = 0.0


func reset_for_new_room(carry_over_charge: float = -1.0) -> void:
	if carry_over_charge >= 0.0:
		overcharge = clampf(carry_over_charge, 0.0, max_overcharge)
	room_cleared = false
	room_overcharge_accumulated = 0.0


func tick_timers(delta: float) -> void:
	if heavy_cd_timer > 0.0:
		heavy_cd_timer = maxf(0.0, heavy_cd_timer - delta)


## Adds Overcharge strictly when room_cleared == false (blocks out-of-combat reload/air-firing farming!).
func gain_overcharge(amount: float) -> float:
	if room_cleared or amount <= 0.0:
		return 0.0
	var before: float = overcharge
	overcharge = clampf(overcharge + amount, 0.0, max_overcharge)
	var actual_delta: float = overcharge - before
	room_overcharge_accumulated += amount
	return actual_delta


func on_primary_firing_hit(is_final_round: bool) -> float:
	# Awarded ONCE per firing action that hits >= 1 enemy (shotgun pellets do not multiply base energy)
	var gain: float = BalanceConfigScript.CHARGE_FINAL_ROUND if is_final_round else BalanceConfigScript.CHARGE_NORMAL_HIT
	return gain_overcharge(gain)


func on_perfect_reload() -> float:
	return gain_overcharge(BalanceConfigScript.CHARGE_PERFECT_RELOAD)


func on_dodge_graze() -> float:
	return gain_overcharge(BalanceConfigScript.CHARGE_DODGE_GRAZE)


func on_weakpoint_interrupt() -> float:
	return gain_overcharge(BalanceConfigScript.CHARGE_INTERRUPT)


func on_dynamo_core_proc(dynamo_bonus: float) -> float:
	return gain_overcharge(dynamo_bonus)


## Evaluates GDD #4 Formula 1 (Expected Room Overcharge Yield & Heavy Cast Ratio).
static func compute_expected_room_overcharge(n_hits: int, n_finals: int, n_reloads: int, n_grazes: int, n_interrupts: int, n_dynamo: int, dynamo_bonus: float, is_cleared: bool = false) -> float:
	if is_cleared:
		return 0.0
	return (
		float(n_hits) * BalanceConfigScript.CHARGE_NORMAL_HIT
		+ float(n_finals) * BalanceConfigScript.CHARGE_FINAL_ROUND
		+ float(n_reloads) * BalanceConfigScript.CHARGE_PERFECT_RELOAD
		+ float(n_grazes) * BalanceConfigScript.CHARGE_DODGE_GRAZE
		+ float(n_interrupts) * BalanceConfigScript.CHARGE_INTERRUPT
		+ float(n_dynamo) * dynamo_bonus
	)


func can_cast_heavy(heavy_cost: float) -> bool:
	return heavy_cd_timer <= 0.0 and overcharge >= heavy_cost


func try_cast_heavy(heavy_cost: float, cooldown_sec: float) -> bool:
	if not can_cast_heavy(heavy_cost):
		return false
	overcharge = maxf(0.0, overcharge - heavy_cost)
	heavy_cd_timer = maxf(0.25, cooldown_sec)
	return true


func try_spend_overdrive_bet() -> bool:
	if overcharge < BalanceConfigScript.OVERDRIVE_BET_COST:
		return false
	overcharge -= BalanceConfigScript.OVERDRIVE_BET_COST
	return true
