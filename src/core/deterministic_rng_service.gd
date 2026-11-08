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


## Rolls 4-Tier Rarity ("COMMON", "RARE", "EPIC", "LEGENDARY") using GDD #9 weights + Pity Accumulator.
func roll_rarity(stratum_idx: int, has_overdrive_bet: bool, node_idx: int, roll_idx: int = 0) -> String:
	var coord_rng := get_coordinate_rng("LOOT", stratum_idx, node_idx, roll_idx)
	var w_common: float = maxf(0.0, 58.0 - 4.5 * float(stratum_idx - 1)) * (0.0 if has_overdrive_bet else 1.0)
	var w_rare: float = 28.0 + 1.5 * float(stratum_idx - 1) + (27.0 if has_overdrive_bet else 0.0)
	var w_epic: float = (11.0 + 2.0 * float(stratum_idx - 1)) * (3.0 if has_overdrive_bet else 1.0) + epic_pity_bonus * 100.0
	var w_leg: float = (3.0 + 1.2 * float(stratum_idx - 1)) * (4.0 if has_overdrive_bet else 1.0) + epic_pity_bonus * 35.0

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
		epic_pity_bonus += 0.15 if has_overdrive_bet else 0.08
	return chosen
