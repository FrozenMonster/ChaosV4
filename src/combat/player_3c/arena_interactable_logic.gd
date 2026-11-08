extends RefCounted
class_name ArenaInteractableLogic
## Unified Proximity [E] & Ranged-Hit Tactical Arena Interactables (GDD #2 & ADR-003).
## Replaces derivative table-flipping with customizable effect payloads (~115 lines).

var interactables: Array[Dictionary] = []
var _next_uid: int = 1


func clear_all() -> void:
	interactables.clear()


func spawn_interactable(data: Dictionary, world_pos: Vector2, rect_size: Vector2 = Vector2(96.0, 36.0)) -> int:
	var uid: int = _next_uid
	_next_uid += 1
	var entry := {
		"uid": uid,
		"id": data.get("id", &"base:deploy_shield"),
		"trigger_mode": data.get("trigger_mode", &"PROXIMITY_KEY_E"),
		"effect_type": data.get("effect_type", &"DEPLOY_SHIELD_COVER"),
		"pos": world_pos,
		"rect": Rect2(world_pos - rect_size * 0.5, rect_size),
		"hp": float(data.get("durability_hp", 60.0)),
		"alive": true,
		"activated": false,
		"uses_left": int(data.get("effect_params", {}).get("uses", 5)),
		"effect_params": data.get("effect_params", {})
	}
	interactables.append(entry)
	return uid


## Handles pressing [E] near any unactivated PROXIMITY_KEY_E interactable within 40.0 px.
func try_trigger_proximity_e(player_pos: Vector2, aim_dir: Vector2) -> Dictionary:
	var best_idx: int = -1
	var best_dist: float = 99999.0
	for i in range(interactables.size()):
		var it: Dictionary = interactables[i]
		if not it["alive"] or it["activated"]:
			continue
		if it["trigger_mode"] != &"PROXIMITY_KEY_E":
			continue
		if (it["rect"] as Rect2).grow(40.0).has_point(player_pos):
			var d: float = player_pos.distance_to(it["pos"])
			if d < best_dist:
				best_dist = d
				best_idx = i

	if best_idx < 0:
		return {"triggered": false}

	var target: Dictionary = interactables[best_idx]
	target["activated"] = true
	var eff: StringName = target["effect_type"]
	match eff:
		&"DEPLOY_SHIELD_COVER":
			return {
				"triggered": true,
				"uid": target["uid"],
				"effect_type": eff,
				"pos": target["pos"],
				"clear_bullet_radius": 28.0,
				"barrier_rect": target["rect"]
			}
		&"OVERCHARGE_CAPACITOR":
			target["alive"] = false
			return {
				"triggered": true,
				"uid": target["uid"],
				"effect_type": eff,
				"pos": target["pos"],
				"overcharge_grant": 22.0,
				"stun_radius": 110.0
			}
		&"KINETIC_LAUNCHPAD":
			target["activated"] = false # Reusable launchpad
			return {
				"triggered": true,
				"uid": target["uid"],
				"effect_type": eff,
				"pos": target["pos"],
				"launch_target": player_pos + aim_dir.normalized() * 260.0,
				"landing_damage": 35.0
			}
	return {"triggered": true, "uid": target["uid"], "effect_type": eff, "pos": target["pos"]}


## Handles player projectile striking any RANGED_HIT interactable within 22.0 px.
func try_trigger_ranged_hit(bullet_pos: Vector2, bullet_dir: Vector2) -> Dictionary:
	for it in interactables:
		if not it["alive"] or it["trigger_mode"] != &"RANGED_HIT":
			continue
		if bullet_pos.distance_to(it["pos"]) <= 22.0:
			var eff: StringName = it["effect_type"]
			if eff == &"PRISM_BULLET_SPLIT":
				it["uses_left"] = int(it["uses_left"]) - 1
				if int(it["uses_left"]) <= 0:
					it["alive"] = false
				var dirs: Array[Vector2] = []
				var base_d: Vector2 = bullet_dir.normalized() if bullet_dir.length_squared() > 0.01 else Vector2.UP
				for k in range(5):
					dirs.append(base_d.rotated(deg_to_rad(-60.0 + float(k) * 30.0)))
				return {
					"triggered": true,
					"uid": it["uid"],
					"effect_type": eff,
					"pos": it["pos"],
					"split_dirs": dirs,
					"split_damage": 22.0
				}
			elif eff == &"CRYO_SLOW_FIELD":
				it["alive"] = false
				return {
					"triggered": true,
					"uid": it["uid"],
					"effect_type": eff,
					"pos": it["pos"],
					"zone_radius": 140.0,
					"duration": 3.5,
					"slow_mult": 0.50
				}
			else: # EXPLOSIVE_BLAST
				it["alive"] = false
				return {
					"triggered": true,
					"uid": it["uid"],
					"effect_type": &"EXPLOSIVE_BLAST",
					"pos": it["pos"],
					"blast_radius": 135.0,
					"blast_damage": 65.0
				}
	return {"triggered": false}
