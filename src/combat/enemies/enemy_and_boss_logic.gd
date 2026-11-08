extends RefCounted
class_name EnemyAndBossLogic
## 3-Tier Enemy AI, Elite Plugins, 4D Boss Part-Breaks & Crash-Proof Entity UID Registry (GDD #6 & ADR-004).
## Pure RefCounted core (~135 lines): monotonic integer entity_uid handles eliminate freed-instance crashes.

const STRATUM_HP_SLOPE: float = 0.22
const ENDLESS_LOOP_MULT: float = 1.35
const OVERDRIVE_BET_HP_BONUS: float = 0.25
const DPS_SOFT_CAP_PCT: float = 0.18
const DPS_OVERFLOW_ATTENUATION: float = 0.35

var _entities_by_uid: Dictionary = {} # entity_uid (int) -> Dictionary
var _next_entity_uid: int = 1001


func clear_all() -> void:
	_entities_by_uid.clear()


## Computes GDD #6 Formula 1 (Stratum, Overdrive Bet & Endless Loop Enemy HP Scaling).
static func compute_scaled_max_hp(base_hp: float, stratum_idx: int, endless_loops: int, has_overdrive_bet: bool) -> float:
	var s_mult: float = 1.0 + STRATUM_HP_SLOPE * float(maxi(1, stratum_idx) - 1)
	var l_mult: float = pow(ENDLESS_LOOP_MULT, float(maxi(0, endless_loops)))
	var b_mult: float = (1.0 + OVERDRIVE_BET_HP_BONUS) if has_overdrive_bet else 1.0
	return round(base_hp * s_mult * l_mult * b_mult)


## Spawns a Tier 1 (Fodder), Tier 2 (Elite), or Tier 3 (Boss) entity and returns its crash-proof integer entity_uid.
func spawn_enemy(config: Dictionary, stratum_idx: int = 1, endless_loops: int = 0, has_bet: bool = false) -> int:
	var uid: int = _next_entity_uid
	_next_entity_uid += 1
	var tier: int = int(config.get("tier", 1)) # 1=Fodder, 2=Elite, 3=Boss
	var max_hp: float = compute_scaled_max_hp(float(config.get("base_hp", 85.0)), stratum_idx, endless_loops, has_bet)
	var parts: Dictionary = {}
	for part_cfg in config.get("boss_parts", []):
		parts[StringName(str(part_cfg["part_id"]))] = {
			"hp": float(part_cfg.get("hp", 350.0)),
			"max_hp": float(part_cfg.get("hp", 350.0)),
			"destroyed": false,
			"disables_attack_id": StringName(str(part_cfg.get("disables_attack_id", "")))
		}

	_entities_by_uid[uid] = {
		"uid": uid,
		"id": StringName(str(config.get("id", "burst_bot"))),
		"tier": tier,
		"hp": max_hp,
		"max_hp": max_hp,
		"alive": true,
		"phase": 1,
		"windup_timer": 0.0,
		"window_dmg_accum": 0.0,
		"stagger_timer": 0.0,
		"rolling_1s_dmg": 0.0,
		"elite_plugins": config.get("elite_plugins", []),
		"front_shield_active": (config.get("elite_plugins", []) as Array).has("DirectionalShieldComponent"),
		"boss_parts": parts,
		"disabled_attacks": []
	}
	return uid


## Crash-Proof Lookup (ADR-004): returns empty dict if entity_uid died or was recycled.
func get_alive(uid: int) -> Dictionary:
	if not _entities_by_uid.has(uid):
		return {}
	var ent: Dictionary = _entities_by_uid[uid]
	return ent if ent.get("alive", false) else {}


## Starts a Weak-Point Interrupt Wind-Up strictly on Elites (Tier 2) and Bosses (Tier 3); Fodder (Tier 1) ignored!
func start_weakpoint_windup(uid: int, duration_sec: float = 0.85) -> bool:
	var ent: Dictionary = get_alive(uid)
	if ent.is_empty() or int(ent["tier"]) <= 1:
		return false
	ent["windup_timer"] = duration_sec
	ent["window_dmg_accum"] = 0.0
	return true


## Evaluates GDD #6 Formula 2 (Boss Rolling 1s DPS Soft-Cap & Interrupt Bypass).
static func evaluate_boss_damage(raw_dmg: float, is_interrupt_or_part_break: bool, rolling_1s_dmg: float, boss_max_hp: float) -> float:
	if is_interrupt_or_part_break or rolling_1s_dmg <= boss_max_hp * DPS_SOFT_CAP_PCT:
		return raw_dmg
	return raw_dmg * DPS_OVERFLOW_ATTENUATION


## Applies damage to an enemy or destructible BossPartNode, resolving Weak-Point Interrupts (+22⚡) and Part Breaks.
func apply_damage(uid: int, raw_dmg: float, is_final_or_heavy: bool, hit_part_id: StringName = &"") -> Dictionary:
	var ent: Dictionary = get_alive(uid)
	if ent.is_empty():
		return {"hit": false}

	var tier: int = int(ent["tier"])
	var dmg: float = raw_dmg * (1.30 if float(ent["stagger_timer"]) > 0.0 else 1.0)
	var triggered_interrupt: bool = false
	var part_broken_id: StringName = &""

	# Dimension B: Destructible BossPartNode priority (GDD #6 Edge Case)
	var parts: Dictionary = ent["boss_parts"]
	if hit_part_id != &"" and parts.has(hit_part_id) and not parts[hit_part_id]["destroyed"]:
		var p: Dictionary = parts[hit_part_id]
		p["hp"] = maxf(0.0, float(p["hp"]) - dmg)
		if float(p["hp"]) <= 0.0:
			p["destroyed"] = true
			part_broken_id = hit_part_id
			triggered_interrupt = true
			(ent["disabled_attacks"] as Array).append(p["disables_attack_id"])
			ent["stagger_timer"] = 2.5
			ent["windup_timer"] = 0.0

	# Elite/Boss Weak-Point Interrupt Check (Final Round, Heavy Spender, or >=45 burst damage)
	if tier >= 2 and float(ent["windup_timer"]) > 0.0:
		ent["window_dmg_accum"] = float(ent["window_dmg_accum"]) + dmg
		if is_final_or_heavy or float(ent["window_dmg_accum"]) >= 45.0:
			triggered_interrupt = true
			ent["windup_timer"] = 0.0
			ent["stagger_timer"] = 1.8

	if tier == 3:
		dmg = evaluate_boss_damage(dmg, triggered_interrupt, float(ent["rolling_1s_dmg"]), float(ent["max_hp"]))
		ent["rolling_1s_dmg"] = float(ent["rolling_1s_dmg"]) + dmg

	ent["hp"] = maxf(0.0, float(ent["hp"]) - dmg)
	if float(ent["hp"]) <= 0.0:
		ent["alive"] = false

	return {
		"hit": true,
		"final_dmg": dmg,
		"interrupted": triggered_interrupt,
		"overcharge_award": 22.0 if triggered_interrupt else 0.0,
		"part_broken": part_broken_id,
		"killed": not ent["alive"]
	}
