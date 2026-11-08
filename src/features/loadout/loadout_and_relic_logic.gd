extends RefCounted
class_name LoadoutAndRelicLogic
## 7-Slot Loadout Schema, 80/20 Composable When->If->Do Item Engine & Salvage Economy (GDD #5 & ADR-003).
## Pure RefCounted core (~130 lines): manages 3 Armory + 4 Tactical slots, mutex filtering, and Bullet Decorators.

const EquipmentSchemasScript = preload("res://src/core/schemas/equipment_schemas.gd")
const PASSIVE_SLOT_CAP: int = 3
const MAGNET_SALVAGE_BONUS: float = 0.50

var slot_primary: Dictionary = {}
var slot_heavy: Dictionary = {}
var slot_dynamo: Dictionary = {}
var slot_active: Dictionary = {}
var slot_passives: Array[Dictionary] = [] # Strictly capped at 3 slots ([7], [8], [9])
var pending_passive_offer: Dictionary = {}
var bounty_chips: int = 0


func has_passive_id(relic_id: StringName) -> bool:
	for p in slot_passives:
		if p.get("id", &"") == relic_id:
			return true
	return false


func has_exclusivity_group(group_tag: StringName) -> bool:
	if group_tag == &"":
		return false
	for p in slot_passives:
		if p.get("exclusivity_group", &"") == group_tag:
			return true
	return false


## Filters a candidate loot pool to exclude duplicates and mutex-conflicting items (ADR-003 Rule B).
func filter_eligible_relic_pool(candidates: Array[Dictionary]) -> Array[Dictionary]:
	var valid: Array[Dictionary] = []
	for item in candidates:
		var r_id: StringName = item.get("id", &"")
		var grp: StringName = item.get("exclusivity_group", &"")
		if has_passive_id(r_id) or has_exclusivity_group(grp):
			continue
		valid.append(item)
	return valid


## Computes GDD #5 Formula 2 (Equipment Salvage Bounty Chip Yield).
func compute_salvage_payout(item_data: Dictionary) -> int:
	var base_chips: int = int(item_data.get("salvage_chip_value", EquipmentSchemasScript.get_salvage_chips_for_rarity(str(item_data.get("rarity_tier", "COMMON")))))
	var has_magnet: bool = has_passive_id(&"base:bounty_audit_magnet")
	return int(round(float(base_chips) * (1.0 + (MAGNET_SALVAGE_BONUS if has_magnet else 0.0))))


## Equips a Passive Relic if slots < 3, auto-salvages duplicates, or enters AWAITING_PASSIVE_SWAP if 3/3 full.
func try_pickup_passive_relic(relic_data: Dictionary) -> Dictionary:
	var norm: Dictionary = EquipmentSchemasScript.make_passive_relic_data(relic_data)
	if has_passive_id(norm["id"]):
		var dup_chips: int = compute_salvage_payout(norm)
		bounty_chips += dup_chips
		return {"status": &"DUPLICATE_SALVAGED", "chips_gained": dup_chips}

	if slot_passives.size() < PASSIVE_SLOT_CAP:
		slot_passives.append(norm)
		return {"status": &"EQUIPPED", "slot_index": slot_passives.size() - 1}

	pending_passive_offer = norm
	return {"status": &"AWAITING_PASSIVE_SWAP", "candidate": norm}


## Resolves pressing [7], [8], or [9] when passive slots are full (3/3).
func swap_passive_slot(slot_index: int) -> Dictionary:
	if pending_passive_offer.is_empty() or slot_index < 0 or slot_index >= slot_passives.size():
		return {"swapped": false}
	var evicted: Dictionary = slot_passives[slot_index]
	var chips: int = compute_salvage_payout(evicted)
	slot_passives[slot_index] = pending_passive_offer
	pending_passive_offer = {}
	bounty_chips += chips
	return {"swapped": true, "evicted_id": evicted["id"], "chips_gained": chips}


## Resolves pressing [G] or walking out of the room with an uncollected pending Passive Relic.
func salvage_pending_offer() -> int:
	if pending_passive_offer.is_empty():
		return 0
	var chips: int = compute_salvage_payout(pending_passive_offer)
	bounty_chips += chips
	pending_passive_offer = {}
	return chips


## Evaluates Additive Bullet Decorators across all equipped Passive Relics (GDD #5 Rule 4).
func apply_bullet_decorators(base_bullet: Dictionary, is_final_round: bool) -> Dictionary:
	var out: Dictionary = base_bullet.duplicate()
	for p in slot_passives:
		var hook: StringName = p.get("trigger_hook", &"")
		if hook == &"ON_FINAL_ROUND_FIRE" and not is_final_round:
			continue
		for act in p.get("atomic_actions", []):
			if act.get("action", "") == "ACT_ADD_BULLET_DECORATOR":
				out["pierce_count"] = int(out.get("pierce_count", 0)) + int(act.get("pierce_add", 0))
				out["bounce_count"] = int(out.get("bounce_count", 0)) + int(act.get("bounce_add", 0))
				out["homing_strength"] = clampf(float(out.get("homing_strength", 0.0)) + float(act.get("homing_add", 0.0)), 0.0, 12.0)
				out["dmg"] = float(out.get("dmg", 10.0)) * (1.0 + float(act.get("dmg_mult", 0.0)))
	return out
