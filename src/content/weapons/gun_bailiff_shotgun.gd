extends RefCounted
class_name GunBailiffShotgun
## Self-Contained Primary Weapon: Bailiff Pump-Shotgun (GDD #4 & ADR-003 Single-File Locality).
## Editing the Shotgun's late sweet spot (0.65-0.81), Dragon's Breath Final Round, or Kinetic Blast Wave touches ONLY this file (~65 lines).

var bonus_pellets_next_shot: int = 0


func get_profile() -> Dictionary:
	return {
		"id": &"base:gun_bailiff_shotgun",
		"display_name_zh": "催收员重型泵动霰弹",
		"rarity_tier": "LEGENDARY",
		"mag_size": 4,
		"fire_interval": 0.46,
		"base_damage": 11.0,
		"bullet_speed": 720.0,
		"reload_time": 1.35,
		"sweet_start": 0.65,
		"sweet_end": 0.81,
		"final_round_mult": 2.8,
		"signature_buff_id": &"kinetic_blast_wave",
		"signature_buff_name_zh": "【膛压过载震波】125px大清弹环+下发霰弹+3弹片"
	}


## Triggered when the player hits the [0.65..0.81] Late-Bar Heavy Sweet Spot on [R].
func on_perfect_reload_activated() -> Dictionary:
	bonus_pellets_next_shot = 3
	return {
		"buff_id": &"kinetic_blast_wave",
		"shockwave_clear_radius": 125.0,
		"shockwave_aoe_damage": 25.0,
		"bonus_pellets_granted": 3
	}


func build_shot_requests(muzzle_pos: Vector2, aim_dir: Vector2, is_final_round: bool, _buff_active: bool) -> Array[Dictionary]:
	var p: Dictionary = get_profile()
	var dmg: float = float(p["base_damage"])
	var spd: float = float(p["bullet_speed"])
	var clean_dir: Vector2 = aim_dir.normalized()
	var reqs: Array[Dictionary] = []

	if is_final_round:
		bonus_pellets_next_shot = 0
		for ang_deg in [-20.0, -10.0, 0.0, 10.0, 20.0]:
			var d: Vector2 = clean_dir.rotated(deg_to_rad(ang_deg))
			reqs.append({
				"pos": muzzle_pos,
				"vel": d * (spd * 1.15),
				"dmg": dmg * float(p["final_round_mult"]),
				"team": &"player",
				"radius": 8.0,
				"tier": 2,
				"pierce_count": 3
			})
		return reqs

	var pellet_count: int = 5 + bonus_pellets_next_shot
	bonus_pellets_next_shot = 0
	for i in range(pellet_count):
		var ang_deg: float = -18.0 + float(i) * (36.0 / float(maxi(1, pellet_count - 1)))
		var d: Vector2 = clean_dir.rotated(deg_to_rad(ang_deg))
		reqs.append({
			"pos": muzzle_pos,
			"vel": d * spd,
			"dmg": dmg,
			"team": &"player",
			"radius": 5.5,
			"tier": 1,
			"pierce_count": 0
		})
	return reqs
