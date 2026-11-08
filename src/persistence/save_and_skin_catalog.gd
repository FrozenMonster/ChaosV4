extends RefCounted
class_name SaveAndSkinCatalog
## Mechanics-to-Lore ThemeSkinCatalog, 3-Phase DLC/MOD ContentRegistry & Atomic Save Logic (GDD #11 & ADR-006).
## Pure RefCounted core (~115 lines): enables instant world re-skinning and zero-rewrite MOD/DLC packs.

const SPARKS_PER_ROOM: float = 2.0
const SPARKS_PER_BOSS: float = 20.0
const SPARKS_PER_BET: float = 6.0
const SPARKS_PER_LOOP: float = 35.0
const PACT_BONUS_STEP: float = 0.15

const BASE_UNLOCK_COST_BY_RARITY: Dictionary = {
	"COMMON": 25.0,
	"RARE": 45.0,
	"EPIC": 75.0,
	"LEGENDARY": 120.0
}

# Hot-swappable skin dictionary: replacing this table re-themes the entire game with 0 code or save changes!
var active_skin_table: Dictionary = {
	&"base:currency_in_run": "悬赏工分币",
	&"base:currency_meta": "超载星核火种",
	&"base:npc_specialist_merchant": "「老烟枪」雷克斯",
	&"base:npc_specialist_smith": "「炸膛大师」巴克",
	&"base:rival_sniper": "「卷王猎人」薇拉",
	&"base:hub_title": "「讨薪号」星际赏金飞船"
}

# 3-Phase ContentRegistry ("base:*", "dlc_*:*", "mod_*:*")
var registered_content: Dictionary = {} # StringName("namespace:id") -> Dictionary


func get_skin_text(functional_id: StringName, fallback_zh: String = "") -> String:
	if active_skin_table.has(functional_id):
		return str(active_skin_table[functional_id])
	return fallback_zh if fallback_zh != "" else str(functional_id)


func apply_skin_override_table(new_skin_dict: Dictionary) -> void:
	for k in new_skin_dict.keys():
		active_skin_table[StringName(str(k))] = str(new_skin_dict[k])


## Registers an item/weapon/enemy from Base Game, DLC (.pck), or Workshop MOD (user://mods/) with namespace isolation.
func register_content_entry(pack_namespace: String, raw_id: String, payload: Dictionary) -> StringName:
	var ns: String = pack_namespace.strip_edges().to_lower()
	var clean_id: String = raw_id.strip_edges().to_lower()
	var full_key := StringName(ns + ":" + clean_id)
	var copy: Dictionary = payload.duplicate()
	copy["id"] = full_key
	copy["pack_namespace"] = ns
	registered_content[full_key] = copy
	return full_key


## Computes GDD #11 Formula 1 (Run Settlement Meta-Currency Payout in Overdrive Sparks).
static func compute_run_sparks_earned(rooms_cleared: int, bosses_defeated: int, bets_won: int, endless_loops: int, pact_rank: int) -> int:
	var base_sparks: float = (
		float(rooms_cleared) * SPARKS_PER_ROOM
		+ float(bosses_defeated) * SPARKS_PER_BOSS
		+ float(bets_won) * SPARKS_PER_BET
		+ float(endless_loops) * SPARKS_PER_LOOP
	)
	var pact_mult: float = 1.0 + PACT_BONUS_STEP * float(maxi(0, pact_rank))
	return int(round(base_sparks * pact_mult))


## Computes GDD #11 Formula 2 (Blueprint Meta-Unlock Cost Curve).
static func compute_blueprint_unlock_cost(rarity: String, tier_depth: int) -> int:
	var base_cost: float = float(BASE_UNLOCK_COST_BY_RARITY.get(rarity.to_upper(), 45.0))
	return int(round(base_cost * (1.0 + 0.12 * float(clampi(tier_depth, 0, 4)))))


## Serializes payload with SHA-256 integrity hash for atomic .sav + .bak backup verification.
static func pack_save_envelope(data: Dictionary) -> Dictionary:
	var json_str: String = JSON.stringify(data, "", true)
	return {
		"sha256": json_str.sha256_text(),
		"payload_json": json_str
	}


static func unpack_and_verify_save_envelope(envelope: Dictionary, backup_envelope: Dictionary = {}) -> Dictionary:
	var json_str: String = str(envelope.get("payload_json", ""))
	var expected_hash: String = str(envelope.get("sha256", ""))
	if json_str != "" and json_str.sha256_text() == expected_hash:
		var parsed = JSON.parse_string(json_str)
		if typeof(parsed) == TYPE_DICTIONARY:
			return {"valid": true, "restored_from_backup": false, "data": parsed}

	# Automatic fallback to .bak if primary save was corrupted!
	var bak_json: String = str(backup_envelope.get("payload_json", ""))
	var bak_hash: String = str(backup_envelope.get("sha256", ""))
	if bak_json != "" and bak_json.sha256_text() == bak_hash:
		var bak_parsed = JSON.parse_string(bak_json)
		if typeof(bak_parsed) == TYPE_DICTIONARY:
			return {"valid": true, "restored_from_backup": true, "data": bak_parsed}

	return {"valid": false, "restored_from_backup": false, "data": {}}
