extends RefCounted
class_name PitStopAndRivalLogic
## Randomized Black-Market, 4-Axis Forge (+1 HP Heal Cap) & 3-Role NPC/Rival Ecosystem (GDD #9 & ADR-003/005).
## Pure RefCounted core (~135 lines): handles Old Rex's Blind Box, Bucky's Forge, and Rival->Playable state.

const EquipmentSchemasScript = preload("res://src/core/schemas/equipment_schemas.gd")
const DeterministicRNGScript = preload("res://src/core/deterministic_rng_service.gd")

const STRICT_HEAL_AMOUNT: int = 1
const BLIND_BOX_COST: int = 60
const REROLL_COSTS: Array[int] = [25, 50, 90]

var rng_service: RefCounted
var reroll_count_in_shop: int = 0
var ration_purchases_in_run: int = 0

# 3-Category Cavern NPC & Rival States
var rex_star_chart_unlocked: bool = false
var bucky_exoskeleton_unlocked: bool = false
var rival_states: Dictionary = {
	&"vesper": &"STRANGER_RIVAL", # STRANGER_RIVAL -> AMBUSH_HIDDEN_BOSS -> SHIP_ALLY -> PLAYABLE_GUNBOY
	&"specimen_y_jr": &"STRANGER_RIVAL"
}


func _init(rng: RefCounted = null) -> void:
	rng_service = rng if rng != null else DeterministicRNGScript.new("X9-G7K2")


## Computes GDD #9 Formula 2 (Black-Market Dynamic Item Price).
func compute_shop_price(rarity: String, stratum_idx: int, is_flash_discount: bool, is_contraband_overclock: bool) -> int:
	var base: float = float(EquipmentSchemasScript.get_shop_price_for_rarity(rarity))
	var s_mult: float = 1.0 + 0.06 * float(maxi(1, stratum_idx) - 1)
	var tag_mult: float = 0.50 if is_flash_discount else (1.30 if is_contraband_overclock else 1.0)
	var vip_mult: float = 0.85 if rex_star_chart_unlocked else 1.0
	return int(round(base * s_mult * tag_mult * vip_mult))


func get_current_ration_price() -> int:
	return 65 if ration_purchases_in_run == 0 else 110


func get_current_reroll_cost() -> int:
	var idx: int = clampi(reroll_count_in_shop, 0, REROLL_COSTS.size() - 1)
	return REROLL_COSTS[idx]


## Opens Old Rex's 60-Chip Mystery Contraband Blind Box using coordinate-hashed RNG and Overcharge (1 + X%) scaling.
func open_mystery_contraband_box(stratum_idx: int, node_idx: int, box_idx: int = 0, overcharge_x_pct: float = 0.0) -> Dictionary:
	var box_rng: RandomNumberGenerator = rng_service.call("get_coordinate_rng", "SHOP_FORGE", stratum_idx, node_idx, 100 + box_idx)
	var boost_mult: float = 1.0 + maxf(0.0, overcharge_x_pct)
	var discounted_cost: int = int(round(float(BLIND_BOX_COST) / (1.0 + 0.35 * maxf(0.0, overcharge_x_pct))))
	var high_gear_chance: float = clampf(0.50 * (1.0 + 0.30 * maxf(0.0, overcharge_x_pct)), 0.0, 0.78)
	var roll: float = box_rng.randf()
	if roll < high_gear_chance:
		var r_pick: float = box_rng.randf()
		var leg_thresh: float = maxf(0.60, 0.85 - 0.15 * maxf(0.0, overcharge_x_pct))
		var rarity: String = "LEGENDARY" if r_pick >= leg_thresh else ("EPIC" if r_pick >= 0.40 else "RARE")
		return {"outcome": &"HIGH_TIER_GEAR", "rarity_tier": rarity, "cost": discounted_cost, "boost_mult": boost_mult}
	elif roll < 0.82:
		var jackpot_chips: int = int(round(float(box_rng.randi_range(90, 130)) * boost_mult))
		return {"outcome": &"RESOURCE_JACKPOT", "chips_awarded": jackpot_chips, "overcharge_awarded": 50.0, "cost": discounted_cost, "boost_mult": boost_mult}
	else:
		return {"outcome": &"CORPORATE_ELITE_AMBUSH", "guaranteed_drop_rarity": "EPIC", "bonus_chips": int(round(45.0 * boost_mult)), "cost": discounted_cost, "boost_mult": boost_mult}


## Applies Bucky's Strict +1 Red Heart Emergency Heal (never exceeds +1 HP per interaction!).
func apply_strict_pit_stop_heal(current_hp: int, max_hp: int) -> int:
	return mini(max_hp, current_hp + STRICT_HEAL_AMOUNT)


## Rolls 3 Rarity-Weighted Upgrade Cards across Bucky's 4 Tuning Axes scaled by Base_Value * (1 + 0.5 * X%).
func roll_bucky_forge_cards(stratum_idx: int, node_idx: int, overcharge_x_pct: float = 0.0) -> Array[Dictionary]:
	var forge_mult: float = 1.0 + 0.50 * maxf(0.0, overcharge_x_pct)
	var axes: Array[Dictionary] = [
		{"axis": &"FIREPOWER_FINAL", "stat": "damage", "stage": "pct_add", "value": 0.18 * forge_mult, "desc": "膛压与尾弹强化"},
		{"axis": &"BALLISTIC_HANDLING", "stat": "fire_interval", "stage": "pct_add", "value": -0.15 * forge_mult, "desc": "机械射速与弹匣调校"},
		{"axis": &"ACTIVE_RELOAD", "stat": "sweet_spot_end", "stage": "flat", "value": 0.08 * forge_mult, "desc": "主动换弹滑轨调校"},
		{"axis": &"EXOSKELETON_DODGE", "stat": "graze_radius", "stage": "pct_add", "value": 0.30 * forge_mult, "desc": "外骨骼擦弹矩阵 (锁死0.42s翻滚时长)"}
	]
	var cards: Array[Dictionary] = []
	for i in range(3):
		var rarity: String = rng_service.call("roll_rarity", stratum_idx, false, node_idx, 200 + i, overcharge_x_pct)
		var template: Dictionary = axes[i % axes.size()].duplicate()
		template["rarity_tier"] = rarity
		template["boost_mult"] = forge_mult
		cards.append(template)
	return cards


## Advances Category C Rival Hunter lifecycle (Stranger -> Ambush Hidden Boss -> Ship Ally -> Playable Gunboy).
func advance_rival_state(rival_id: StringName, defeated_in_boss_fight: bool = false, recruited_in_hub: bool = false) -> StringName:
	var cur: StringName = rival_states.get(rival_id, &"STRANGER_RIVAL")
	if cur == &"STRANGER_RIVAL":
		rival_states[rival_id] = &"AMBUSH_HIDDEN_BOSS"
	elif cur == &"AMBUSH_HIDDEN_BOSS" and defeated_in_boss_fight:
		rival_states[rival_id] = &"SHIP_ALLY"
	elif cur == &"SHIP_ALLY" and recruited_in_hub:
		rival_states[rival_id] = &"PLAYABLE_GUNBOY"
	return rival_states[rival_id]
