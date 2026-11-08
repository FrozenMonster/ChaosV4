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


## Opens Old Rex's 60-Chip Mystery Contraband Blind Box using coordinate-hashed RNG (blocks Alt+F4 save-scumming!).
func open_mystery_contraband_box(stratum_idx: int, node_idx: int, box_idx: int = 0) -> Dictionary:
	var box_rng: RandomNumberGenerator = rng_service.call("get_coordinate_rng", "SHOP_FORGE", stratum_idx, node_idx, 100 + box_idx)
	var roll: float = box_rng.randf()
	if roll < 0.50:
		var r_pick: float = box_rng.randf()
		var rarity: String = "LEGENDARY" if r_pick >= 0.85 else ("EPIC" if r_pick >= 0.45 else "RARE")
		return {"outcome": &"HIGH_TIER_GEAR", "rarity_tier": rarity, "cost": BLIND_BOX_COST}
	elif roll < 0.80:
		var jackpot_chips: int = box_rng.randi_range(90, 130)
		return {"outcome": &"RESOURCE_JACKPOT", "chips_awarded": jackpot_chips, "overcharge_awarded": 50.0, "cost": BLIND_BOX_COST}
	else:
		return {"outcome": &"CORPORATE_ELITE_AMBUSH", "guaranteed_drop_rarity": "EPIC", "bonus_chips": 45, "cost": BLIND_BOX_COST}


## Applies Bucky's Strict +1 Red Heart Emergency Heal (never exceeds +1 HP per interaction!).
func apply_strict_pit_stop_heal(current_hp: int, max_hp: int) -> int:
	return mini(max_hp, current_hp + STRICT_HEAL_AMOUNT)


## Rolls 3 Rarity-Weighted Upgrade Cards across Bucky's 4 Tuning Axes (preserving locked 0.42s dodge duration!).
func roll_bucky_forge_cards(stratum_idx: int, node_idx: int) -> Array[Dictionary]:
	var axes: Array[Dictionary] = [
		{"axis": &"FIREPOWER_FINAL", "stat": "damage", "stage": "pct_add", "value": 0.18, "desc": "膛压与尾弹强化 (+18%伤害)"},
		{"axis": &"BALLISTIC_HANDLING", "stat": "fire_interval", "stage": "pct_add", "value": -0.15, "desc": "机械射速与弹匣调校 (+15%射速)"},
		{"axis": &"ACTIVE_RELOAD", "stat": "sweet_spot_end", "stage": "flat", "value": 0.08, "desc": "主动换弹滑轨调校 (+8%完美甜区宽度)"},
		{"axis": &"EXOSKELETON_DODGE", "stat": "graze_radius", "stage": "pct_add", "value": 0.30, "desc": "外骨骼擦弹矩阵 (+30%擦弹环 & 单滚3次上限, 锁死0.42s翻滚时长)"}
	]
	var cards: Array[Dictionary] = []
	for i in range(3):
		var rarity: String = rng_service.call("roll_rarity", stratum_idx, false, node_idx, 200 + i)
		var template: Dictionary = axes[i % axes.size()].duplicate()
		template["rarity_tier"] = rarity
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
