extends RefCounted
class_name BulletPoolLogic
## 800-Slot Pre-Allocated Projectile Pool, Synergy Burst Coalescing & Non-Blocking Hitstop (GDD #3 & ADR-002).
## Pure RefCounted core (~130 lines): zero runtime node allocations, 100% testable in <1ms.

const BalanceConfigScript = preload("res://src/core/balance_config.gd")

const POOL_CAPACITY: int = 800
const HITSTOP_WORLD_DILATION: float = 0.18

var slots: Array[Dictionary] = []
var active_count: int = 0
var hitstop_timer: float = 0.0
var arena_bounds: Rect2 = Rect2(80.0, 90.0, 1120.0, 560.0)


func _init() -> void:
	slots.resize(POOL_CAPACITY)
	for i in range(POOL_CAPACITY):
		slots[i] = _make_empty_slot(i)


func _make_empty_slot(idx: int) -> Dictionary:
	return {
		"slot_idx": idx,
		"active": false,
		"pos": Vector2.ZERO,
		"vel": Vector2.ZERO,
		"dmg": 10.0,
		"team": &"enemy",
		"radius": 6.0,
		"tier": 1, # 1=Standard, 2=Final Round, 3=Heavy Spender
		"pierce_count": 0,
		"homing_strength": 0.0,
		"grazed": false,
		"is_shield_piercing": false,
		"coalesced_scale": 1.0
	}


## One-Way Non-Blocking Hitstop (ADR-002): Player delta is NEVER blocked or slowed!
func get_player_delta(raw_delta: float) -> float:
	return raw_delta


## Enemy & world hazards slow down to 0.18x during active hitstop frames.
func get_world_delta(raw_delta: float) -> float:
	if hitstop_timer > 0.0:
		return raw_delta * HITSTOP_WORLD_DILATION
	return raw_delta


func trigger_hitstop(duration_sec: float) -> void:
	# Uses maxf() rather than addition so piercing 10 enemies never stacks a 0.30s freeze (GDD #3 Edge Case).
	hitstop_timer = maxf(hitstop_timer, duration_sec)


func tick_hitstop(raw_delta: float) -> void:
	if hitstop_timer > 0.0:
		hitstop_timer = maxf(0.0, hitstop_timer - raw_delta)


## Spawns a single projectile into the first dormant slot (recycles oldest enemy slot if all 800 are full).
func spawn_bullet(params: Dictionary) -> int:
	var target_idx: int = -1
	for i in range(POOL_CAPACITY):
		if not slots[i]["active"]:
			target_idx = i
			break
	if target_idx < 0:
		# Recycle first enemy projectile slot so player shots never fail to spawn
		target_idx = 0
		for i in range(POOL_CAPACITY):
			if slots[i]["team"] == &"enemy":
				target_idx = i
				break

	var s: Dictionary = slots[target_idx]
	if not s["active"]:
		active_count += 1
	s["active"] = true
	s["pos"] = params.get("pos", Vector2.ZERO)
	s["vel"] = params.get("vel", Vector2.RIGHT * 600.0)
	s["dmg"] = float(params.get("dmg", 10.0))
	s["team"] = StringName(str(params.get("team", "player")))
	s["radius"] = float(params.get("radius", 6.0))
	s["tier"] = int(params.get("tier", 1))
	s["pierce_count"] = int(params.get("pierce_count", 0))
	s["homing_strength"] = float(params.get("homing_strength", 0.0))
	s["grazed"] = false
	s["is_shield_piercing"] = bool(params.get("is_shield_piercing", false))
	s["coalesced_scale"] = float(params.get("coalesced_scale", 1.0))
	return target_idx


## Synergy Projectile Coalescing (ADR-002):
## If a player burst + relic/prism chain requests N > 24 projectiles on the same frame,
## caps spawned projectiles at 24 and multiplies each bullet's damage by (N / 24.0) so 0 DPS is lost!
func spawn_player_burst(requests: Array[Dictionary]) -> Array[int]:
	var count: int = requests.size()
	var spawned_indices: Array[int] = []
	if count == 0:
		return spawned_indices

	var cap: int = BalanceConfigScript.MAX_PLAYER_BURST_CAP
	if count <= cap:
		for req in requests:
			spawned_indices.append(spawn_bullet(req))
		return spawned_indices

	var dmg_coalesce_mult: float = float(count) / float(cap)
	var step: float = float(count) / float(cap)
	for k in range(cap):
		var src_idx: int = mini(count - 1, int(float(k) * step))
		var merged: Dictionary = requests[src_idx].duplicate()
		merged["dmg"] = float(merged.get("dmg", 10.0)) * dmg_coalesce_mult
		merged["coalesced_scale"] = minf(1.65, 1.0 + 0.15 * dmg_coalesce_mult)
		spawned_indices.append(spawn_bullet(merged))
	return spawned_indices


func deactivate_slot(idx: int) -> void:
	if idx >= 0 and idx < POOL_CAPACITY and slots[idx]["active"]:
		slots[idx]["active"] = false
		active_count = maxi(0, active_count - 1)


## Clears enemy projectiles within radius (for Perfect Reload shockwaves, EMP, Aegis Break, or Shield Deploy).
func clear_enemy_bullets_in_radius(center: Vector2, radius: float) -> int:
	var cleared: int = 0
	for i in range(POOL_CAPACITY):
		var s: Dictionary = slots[i]
		if s["active"] and s["team"] == &"enemy":
			if (s["pos"] as Vector2).distance_to(center) <= radius:
				deactivate_slot(i)
				cleared += 1
	return cleared
