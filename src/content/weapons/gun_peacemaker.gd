extends RefCounted
class_name GunPeacemaker
## Self-Contained Primary Weapon: Peacemaker Revolver (GDD #4 & ADR-003 Single-File Locality).
## Editing the Revolver's reload sweet spot, Final Round, or Gunslinger Focus buff touches ONLY this file (~60 lines).

var guaranteed_crit_shots_left: int = 0


func get_profile() -> Dictionary:
	return {
		"id": &"base:gun_peacemaker",
		"display_name_zh": "维和者重型左轮",
		"rarity_tier": "RARE",
		"mag_size": 6,
		"fire_interval": 0.20,
		"base_damage": 18.0,
		"bullet_speed": 820.0,
		"reload_time": 1.15,
		"sweet_start": 0.42,
		"sweet_end": 0.62,
		"final_round_mult": 2.5,
		"signature_buff_id": &"gunslinger_focus",
		"signature_buff_name_zh": "【快枪手凝神】前2发必暴击(+40%)且2倍弹速"
	}


## Triggered when the player hits the [0.42..0.62] Mid-Bar Sweet Spot on [R].
func on_perfect_reload_activated() -> Dictionary:
	guaranteed_crit_shots_left = 2
	return {
		"buff_id": &"gunslinger_focus",
		"crit_shots_granted": 2,
		"crit_dmg_mult": 1.40,
		"speed_mult": 2.0,
		"shockwave_clear_radius": 85.0
	}


## Builds projectile spawn requests for standard shots vs. Final Round (ammo == 1).
func build_shot_requests(muzzle_pos: Vector2, aim_dir: Vector2, is_final_round: bool, buff_active: bool) -> Array[Dictionary]:
	var p: Dictionary = get_profile()
	var dmg: float = float(p["base_damage"])
	var spd: float = float(p["bullet_speed"])
	if buff_active and guaranteed_crit_shots_left > 0:
		guaranteed_crit_shots_left -= 1
		dmg *= 1.40
		spd *= 2.0
	if is_final_round:
		dmg *= float(p["final_round_mult"])
		return [{
			"pos": muzzle_pos,
			"vel": aim_dir.normalized() * spd,
			"dmg": dmg,
			"team": &"player",
			"radius": 9.0,
			"tier": 2,
			"pierce_count": 99
		}]
	return [{
		"pos": muzzle_pos,
		"vel": aim_dir.normalized() * spd,
		"dmg": dmg,
		"team": &"player",
		"radius": 5.5,
		"tier": 1,
		"pierce_count": 0
	}]
