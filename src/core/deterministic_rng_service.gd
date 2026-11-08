extends RefCounted
class_name DeterministicRNGService
## 6-Stream Coordinate-Hashed Deterministic RNG & Bad-Luck Pity Engine (ADR-005).
## Pure RefCounted class: 100% testable in <1ms in headless mode with zero scene dependencies.

var master_seed_code: String = "X9-G7K2"
var master_seed_u64: int = 0
var epic_pity_bonus: float = 0.0

var stream_topology: RandomNumberGenerator = RandomNumberGenerator.new()
var stream_loot: RandomNumberGenerator = RandomNumberGenerator.new()
var stream_shop_forge: RandomNumberGenerator = RandomNumberGenerator.new()
var stream_spawns: RandomNumberGenerator = RandomNumberGenerator.new()
var stream_combat: RandomNumberGenerator = RandomNumberGenerator.new()
var stream_cosmetic: RandomNumberGenerator = RandomNumberGenerator.new()


func _init(seed_code: String = "X9-G7K2") -> void:
	setup_master_seed(seed_code)


func setup_master_seed(seed_code: String) -> void:
	master_seed_code = seed_code.strip_edges().to_upper()
	master_seed_u64 = master_seed_code.hash()
	epic_pity_bonus = 0.0
	stream_topology.seed = _fork_seed("TOPOLOGY")
	stream_loot.seed = _fork_seed("LOOT")
	stream_shop_forge.seed = _fork_seed("SHOP_FORGE")
	stream_spawns.seed = _fork_seed("SPAWNS")
	stream_combat.seed = _fork_seed("COMBAT")
	stream_cosmetic.randomize()


func _fork_seed(channel_tag: String) -> int:
	return (master_seed_u64 * 1664525 + channel_tag.hash() + 1013904223) & 0x7FFFFFFFFFFFFFFF


## Stateless Coordinate Hash: guarantees (stratum, node, action_idx) rolls the exact same result
## regardless of how many combat bullets were fired or whether the player Alt+F4 reloaded.
func get_coordinate_rng(channel_tag: String, stratum_idx: int, node_idx: int, action_idx: int = 0) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	var h: int = _fork_seed(channel_tag)
	h = ((h * 31 + stratum_idx) * 31 + node_idx) * 31 + action_idx
	rng.seed = h & 0x7FFFFFFFFFFFFFFF
	return rng


## Computes equipment drop probability using the multiplicative formula:
## final_drop_chance = BASE_EQUIP_DROP_CHANCE (0.35) * (1.0 + boost_pct)
static func compute_equipment_drop_chance(overcharge_ratio: float, bet_stacks: int = 0) -> float:
	var x_pct: float = clampf(overcharge_ratio, 0.0, 1.0) * 0.50 + float(clampi(bet_stacks, 0, 3)) * 0.20
	return clampf(0.35 * (1.0 + x_pct), 0.0, 0.95)


## Rolls 4-Tier Rarity ("COMMON", "RARE", "EPIC", "LEGENDARY") using Base_Weight * (1.0 + X%) multiplicative scaling.
func roll_rarity(stratum_idx: int, has_overdrive_bet: bool, node_idx: int, roll_idx: int = 0, overcharge_ratio: float = 0.0) -> String:
	var coord_rng := get_coordinate_rng("LOOT", stratum_idx, node_idx, roll_idx)
	var x_pct: float = clampf(overcharge_ratio, 0.0, 1.0) * 0.80 + (0.40 if has_overdrive_bet else 0.0) + float(maxi(0, stratum_idx - 1)) * 0.10 + epic_pity_bonus
	var w_common: float = 60.0
	var w_rare: float = 26.0 * (1.0 + 0.50 * x_pct)
	var w_epic: float = 11.0 * (1.0 + 1.20 * x_pct)
	var w_leg: float = 3.0 * (1.0 + 2.00 * x_pct)

	var total: float = w_common + w_rare + w_epic + w_leg
	var pick: float = coord_rng.randf() * total
	var chosen: String = "COMMON"
	if pick < w_common:
		chosen = "COMMON"
	elif pick < w_common + w_rare:
		chosen = "RARE"
	elif pick < w_common + w_rare + w_epic:
		chosen = "EPIC"
	else:
		chosen = "LEGENDARY"

	if chosen == "EPIC" or chosen == "LEGENDARY":
		epic_pity_bonus = 0.0
	else:
		epic_pity_bonus += 0.12 if has_overdrive_bet else 0.06
	return chosen
