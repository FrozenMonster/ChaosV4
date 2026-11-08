extends RefCounted
class_name AegisAndDamageLogic
## 3-Tier Ballistic Impact/Recoil Matrix & 3-Pip Overcharge Aegis Shield (GDD #3 & ADR-002/004).
## Enforces zero free room shield refill, 3-pip active reconstruction, and SHIELD_PIERCING rules (~125 lines).

const BalanceConfigScript = preload("res://src/core/balance_config.gd")

const KB_TIER_1_STANDARD: float = 4.0
const KB_TIER_2_FINAL_ROUND: float = 28.0
const KB_TIER_3_HEAVY_WEAPON: float = 45.0

const RECOIL_FINAL_ROUND_PX: float = 4.0
const RECOIL_HEAVY_LIGHT_PX: float = 8.0
const RECOIL_HEAVY_MED_PX: float = 16.0
const RECOIL_HEAVY_ULT_PX: float = 22.0

var hp: int = 6
var max_hp: int = 6
var aegis_shield: int = 1
var max_aegis_shield: int = 1
var aegis_pips: int = 0
var combat_perfect_reload_counter: int = 0
var invuln_timer: float = 0.0
var boss_hitless_eligible: bool = true


func reset_for_new_run(starting_hp: int = 6, starting_shield: int = 1) -> void:
	max_hp = starting_hp
	hp = starting_hp
	max_aegis_shield = starting_shield
	aegis_shield = starting_shield
	aegis_pips = 0
	combat_perfect_reload_counter = 0
	invuln_timer = 0.0
	boss_hitless_eligible = true


## Note: Entering a new room does NOT auto-refill aegis_shield! Only resets per-boss hitless flag if entering Boss room.
func on_enter_new_room(is_boss_room: bool = false) -> void:
	if is_boss_room:
		boss_hitless_eligible = true


func tick_timers(delta: float) -> void:
	if invuln_timer > 0.0:
		invuln_timer = maxf(0.0, invuln_timer - delta)


## Awards +1 Aegis Reconstruction Pip (from RMB Heavy cast, Weak-Point Interrupt, or 3rd combat Perfect Reload).
func award_aegis_pip() -> bool:
	if aegis_shield >= max_aegis_shield:
		return false
	aegis_pips += 1
	if aegis_pips >= BalanceConfigScript.AEGIS_PIPS_REQUIRED:
		aegis_pips = 0
		aegis_shield = mini(max_aegis_shield, aegis_shield + 1)
		return true # Shield reconstructed!
	return false


func record_combat_perfect_reload(room_cleared: bool) -> bool:
	if room_cleared:
		return false
	combat_perfect_reload_counter += 1
	if combat_perfect_reload_counter % BalanceConfigScript.PERFECT_RELOADS_PER_PIP == 0:
		return award_aegis_pip()
	return false


## Resolves incoming hit against Overcharge Aegis Shield vs. SHIELD_PIERCING signature attacks.
func apply_player_hit(damage: int = 1, is_shield_piercing: bool = false) -> Dictionary:
	if invuln_timer > 0.0:
		return {"damaged": false, "reason": &"invulnerable"}

	invuln_timer = BalanceConfigScript.INVULN_DURATION
	if aegis_shield > 0 and not is_shield_piercing:
		aegis_shield -= 1
		# Absorbing a normal hit with Aegis Shield PRESERVES boss_hitless_eligible!
		return {
			"damaged": true,
			"shield_absorbed": true,
			"hp_lost": 0,
			"trigger_aegis_blank_radius": 90.0,
			"boss_hitless_eligible": boss_hitless_eligible
		}

	var actual_loss: int = maxi(1, damage)
	hp = maxi(0, hp - actual_loss)
	boss_hitless_eligible = false
	return {
		"damaged": true,
		"shield_absorbed": false,
		"shield_pierced": is_shield_piercing,
		"hp_lost": actual_loss,
		"boss_hitless_eligible": false
	}


## Computes GDD #3 Formula 1 (Final Enemy Damage).
static func compute_final_enemy_damage(base_dmg: float, is_final_round: bool, final_mult: float, has_reload_buff: bool, passive_dmg_bonus: float) -> float:
	var f_factor: float = final_mult if is_final_round else 1.0
	var r_factor: float = 1.25 if has_reload_buff else 1.0
	return base_dmg * f_factor * r_factor * (1.0 + passive_dmg_bonus)


## Computes GDD #3 Formula 2 (Enemy Knockback Distance by Ballistic Tier 1/2/3).
static func compute_enemy_knockback_px(ballistic_tier: int, knockback_resistance: float = 0.0) -> float:
	var base_kb: float = KB_TIER_1_STANDARD
	if ballistic_tier == 2:
		base_kb = KB_TIER_2_FINAL_ROUND
	elif ballistic_tier == 3:
		base_kb = KB_TIER_3_HEAVY_WEAPON
	return base_kb * clampf(1.0 - knockback_resistance, 0.0, 1.0)


## Computes GDD #3 Formula 3 (Shooter Physical Recoil Slide in Pixels).
static func compute_shooter_recoil_slide_px(is_final_round: bool, is_heavy_shot: bool, heavy_cost: float, is_dodging: bool) -> float:
	if is_dodging:
		return 0.0
	if is_heavy_shot:
		if is_equal_approx(heavy_cost, BalanceConfigScript.HEAVY_COST_LIGHT):
			return RECOIL_HEAVY_LIGHT_PX
		elif is_equal_approx(heavy_cost, BalanceConfigScript.HEAVY_COST_MEDIUM):
			return RECOIL_HEAVY_MED_PX
		return RECOIL_HEAVY_ULT_PX
	if is_final_round:
		return RECOIL_FINAL_ROUND_PX
	return 0.0
