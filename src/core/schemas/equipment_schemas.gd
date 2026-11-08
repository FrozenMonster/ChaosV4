extends RefCounted
class_name EquipmentSchemas
## Validated 7-Slot Loadout, 4-Tier Rarity & ArenaInteractable Data Schemas (ADR-001 & ADR-006).
## Enforces "base:id" namespace prefixes, safe fallback clamping, and rarity economy lookup (~115 lines).

const VALID_RARITIES: Array[String] = ["COMMON", "RARE", "EPIC", "LEGENDARY"]

const RARITY_SHOP_PRICE: Dictionary = {
	"COMMON": 55,
	"RARE": 85,
	"EPIC": 130,
	"LEGENDARY": 190
}

const RARITY_SALVAGE_CHIPS: Dictionary = {
	"COMMON": 15,
	"RARE": 25,
	"EPIC": 40,
	"LEGENDARY": 65
}


static func normalize_namespaced_id(raw_id: String, default_ns: String = "base") -> StringName:
	var clean: String = raw_id.strip_edges().to_lower()
	if clean == "":
		return StringName(default_ns + ":unknown")
	if not clean.contains(":"):
		return StringName(default_ns + ":" + clean)
	return StringName(clean)


static func normalize_rarity(raw_rarity: String) -> String:
	var up: String = raw_rarity.strip_edges().to_upper()
	if VALID_RARITIES.has(up):
		return up
	return "COMMON"


static func get_shop_price_for_rarity(rarity: String) -> int:
	var norm: String = normalize_rarity(rarity)
	return int(RARITY_SHOP_PRICE.get(norm, 55))


static func get_salvage_chips_for_rarity(rarity: String) -> int:
	var norm: String = normalize_rarity(rarity)
	return int(RARITY_SALVAGE_CHIPS.get(norm, 15))


## Validates and clamps PrimaryWeaponData fields so a data typo never crashes a run (GDD #1 Edge Case).
static func make_primary_weapon_data(raw: Dictionary) -> Dictionary:
	var s_start: float = float(raw.get("sweet_spot_start", 0.42))
	var s_end: float = float(raw.get("sweet_spot_end", 0.62))
	if s_start < 0.05 or s_end > 0.95 or s_end <= s_start:
		s_start = 0.42
		s_end = 0.62
	var rarity: String = normalize_rarity(str(raw.get("rarity_tier", "COMMON")))
	return {
		"id": normalize_namespaced_id(str(raw.get("id", "peacemaker"))),
		"display_name_zh": str(raw.get("display_name_zh", "维和者左轮")),
		"rarity_tier": rarity,
		"mag_size": maxi(1, int(raw.get("mag_size", 6))),
		"fire_interval": maxf(0.04, float(raw.get("fire_interval", 0.20))),
		"base_damage": maxf(1.0, float(raw.get("base_damage", 18.0))),
		"bullet_speed": clampf(float(raw.get("bullet_speed", 820.0)), 100.0, 2500.0),
		"reload_time": clampf(float(raw.get("reload_time", 1.15)), 0.25, 4.0),
		"sweet_spot_start": s_start,
		"sweet_spot_end": s_end,
		"final_round_multiplier": maxf(1.0, float(raw.get("final_round_multiplier", 2.5))),
		"signature_buff_id": StringName(str(raw.get("signature_buff_id", "gunslinger_focus"))),
		"shop_price": get_shop_price_for_rarity(rarity),
		"salvage_chip_value": get_salvage_chips_for_rarity(rarity)
	}


static func make_heavy_weapon_data(raw: Dictionary) -> Dictionary:
	var cost: float = float(raw.get("overcharge_cost", 45.0))
	if cost <= 0.0 or cost > 100.0:
		cost = 45.0
	var rarity: String = normalize_rarity(str(raw.get("rarity_tier", "RARE")))
	return {
		"id": normalize_namespaced_id(str(raw.get("id", "swarm_missiles"))),
		"display_name_zh": str(raw.get("display_name_zh", "蜂群微型导弹")),
		"rarity_tier": rarity,
		"overcharge_cost": cost,
		"behavior_type": StringName(str(raw.get("behavior_type", "swarm"))),
		"base_damage": maxf(1.0, float(raw.get("base_damage", 36.0))),
		"cooldown": maxf(0.25, float(raw.get("cooldown", 2.5))),
		"shop_price": get_shop_price_for_rarity(rarity),
		"salvage_chip_value": get_salvage_chips_for_rarity(rarity)
	}


static func make_passive_relic_data(raw: Dictionary) -> Dictionary:
	var rarity: String = normalize_rarity(str(raw.get("rarity_tier", "COMMON")))
	return {
		"id": normalize_namespaced_id(str(raw.get("id", "tesla_mag_well"))),
		"display_name_zh": str(raw.get("display_name_zh", "特斯拉弹匣井")),
		"rarity_tier": rarity,
		"exclusivity_group": StringName(str(raw.get("exclusivity_group", ""))),
		"trigger_hook": StringName(str(raw.get("trigger_hook", "ON_PERFECT_RELOAD"))),
		"condition_filter": StringName(str(raw.get("condition_filter", "ALWAYS"))),
		"atomic_actions": raw.get("atomic_actions", []),
		"stat_modifiers": raw.get("stat_modifiers", {}),
		"shop_price": get_shop_price_for_rarity(rarity),
		"salvage_chip_value": get_salvage_chips_for_rarity(rarity)
	}


static func make_arena_interactable_data(raw: Dictionary) -> Dictionary:
	var t_mode: String = str(raw.get("trigger_mode", "PROXIMITY_KEY_E"))
	if t_mode != "PROXIMITY_KEY_E" and t_mode != "RANGED_HIT":
		t_mode = "PROXIMITY_KEY_E"
	return {
		"id": normalize_namespaced_id(str(raw.get("id", "deploy_shield"))),
		"display_name_zh": str(raw.get("display_name_zh", "液压防爆升盾桩")),
		"trigger_mode": StringName(t_mode),
		"effect_type": StringName(str(raw.get("effect_type", "DEPLOY_SHIELD_COVER"))),
		"durability_hp": maxf(1.0, float(raw.get("durability_hp", 60.0))),
		"effect_params": raw.get("effect_params", {})
	}
