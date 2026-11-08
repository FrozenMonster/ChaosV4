extends RefCounted
class_name GunVectorSMG
## Self-Contained Primary Weapon: Vector Twin-SMG (GDD #4 & ADR-003 Single-File Locality).
## Editing the Twin-SMG's early sweet spot (0.22-0.40), Triple Shock-Fan Final Round, or Overclock Cadence touches ONLY this file (~60 lines).


func get_profile() -> Dictionary:
	return {
		"id": &"base:gun_vector_smg",
		"display_name_zh": "矢量双持冲锋枪",
		"rarity_tier": "EPIC",
		"mag_size": 16,
		"fire_interval": 0.09,
		"base_damage": 9.0,
		"bullet_speed": 760.0,
		"reload_time": 0.95,
		"sweet_start": 0.22,
		"sweet_end": 0.40,
		"final_round_mult": 1.8,
		"signature_buff_id": &"overclock_cadence",
		"signature_buff_name_zh": "【超频狂飙】射速+35%且零散射激光弹道"
	}


## Triggered when the player hits the [0.22..0.40] Early-Bar Speed Sweet Spot on [R].
func on_perfect_reload_activated() -> Dictionary:
	return {
		"buff_id": &"overclock_cadence",
		"fire_rate_bonus": 0.35,
		"spread_override_deg": 0.0,
		"shockwave_clear_radius": 85.0
	}


func get_effective_fire_interval(buff_active: bool) -> float:
	var base_int: float = float(get_profile()["fire_interval"])
	return base_int / 1.35 if buff_active else base_int


func build_shot_requests(muzzle_pos: Vector2, aim_dir: Vector2, is_final_round: bool, _buff_active: bool) -> Array[Dictionary]:
	var p: Dictionary = get_profile()
	var dmg: float = float(p["base_damage"])
	var spd: float = float(p["bullet_speed"])
	var clean_dir: Vector2 = aim_dir.normalized()
	if is_final_round:
		var reqs: Array[Dictionary] = []
		for ang_deg in [-14.0, 0.0, 14.0]:
			var d: Vector2 = clean_dir.rotated(deg_to_rad(ang_deg))
			reqs.append({
				"pos": muzzle_pos,
				"vel": d * (spd * 1.12),
				"dmg": dmg * float(p["final_round_mult"]),
				"team": &"player",
				"radius": 7.0,
				"tier": 2,
				"pierce_count": 2
			})
		return reqs
	return [{
		"pos": muzzle_pos,
		"vel": clean_dir * spd,
		"dmg": dmg,
		"team": &"player",
		"radius": 5.0,
		"tier": 1,
		"pierce_count": 0
	}]
