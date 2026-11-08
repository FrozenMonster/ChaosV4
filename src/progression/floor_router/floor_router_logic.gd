extends RefCounted
class_name FloorRouterLogic
## 7-Node Stratum DAG, 5 Non-Rectangular Footprints, 4 Room Objectives & Hades-Style Exits (GDD #7 & ADR-005).
## Pure RefCounted core (~125 lines): coordinate-hashed room generation & Overdrive Bet math.

const BalanceConfigScript = preload("res://src/core/balance_config.gd")
const DeterministicRNGScript = preload("res://src/core/deterministic_rng_service.gd")

const FOOTPRINTS: Array[String] = ["STANDARD_CHAMBER", "L_BEND_CORRIDOR", "RING_PIT_CORE", "TWIN_BRIDGE_SPAN", "IRREGULAR_CAVERN"]
const OBJECTIVES: Array[String] = ["EXTERMINATION", "SABOTAGE_BEACONS", "OVERDRIVE_SURVIVAL", "CONDUIT_UPLOAD"]
const MAX_CONCURRENT_ENEMIES: int = 7

var rng_service: RefCounted
var stratum_index: int = 1
var node_index: int = 1
var endless_loop_count: int = 0
var stratum_bet_streak: int = 0


func _init(rng: RefCounted = null) -> void:
	rng_service = rng if rng != null else DeterministicRNGScript.new("X9-G7K2")


## Computes GDD #7 Formula 1 (Single-Room Encounter Wave Budget).
static func compute_room_encounter_budget(node_idx: int, stratum_idx: int, has_bet: bool, endless_loops: int) -> int:
	var base: float = 10.0 + 2.0 * float(maxi(1, node_idx) - 1) + 4.0 * float(maxi(1, stratum_idx) - 1)
	var bet_mult: float = 1.35 if has_bet else 1.0
	var loop_mult: float = pow(1.25, float(maxi(0, endless_loops)))
	return int(round(base * bet_mult * loop_mult))


## Computes GDD #7 Formula 2 (Room Bounty Chip Payout & 2.0x Overdrive Bet Multiplier).
static func compute_room_bounty_chips(enemy_base_chips: int, stratum_idx: int, has_bet: bool) -> int:
	var raw: float = float(enemy_base_chips) + 8.0 * float(maxi(1, stratum_idx))
	return int(round(raw * (2.0 if has_bet else 1.0)))


## Generates a deterministic non-repeating room node using coordinate hashing.
func generate_room_node(stratum_idx: int, node_idx: int, has_overdrive_bet: bool, prev_footprint: String = "") -> Dictionary:
	stratum_index = stratum_idx
	node_index = node_idx
	if has_overdrive_bet:
		stratum_bet_streak += 1

	var topo_rng: RandomNumberGenerator = rng_service.call("get_coordinate_rng", "TOPOLOGY", stratum_idx, node_idx, 0)

	# Node 4 is Guaranteed Mid-Stratum Pit-Stop; Node 7 is Stratum Boss
	if node_idx == 4:
		return {"node_type": &"PIT_STOP", "footprint": "STANDARD_CHAMBER", "objective": "SAFE_SANCTUARY", "doors": _roll_exits(topo_rng, 2)}
	if node_idx == 7:
		return {"node_type": &"STRATUM_BOSS", "footprint": "RING_PIT_CORE", "objective": "BOSS_SHOWDOWN", "doors": _roll_exits(topo_rng, 2)}

	# Pick non-repeating footprint
	var fp: String = FOOTPRINTS[topo_rng.randi() % FOOTPRINTS.size()]
	if fp == prev_footprint:
		fp = FOOTPRINTS[(FOOTPRINTS.find(fp) + 1) % FOOTPRINTS.size()]

	# Weighted RoomObjectiveType: 45% EXTERMINATION, 25% SABOTAGE_BEACONS, 15% OVERDRIVE_SURVIVAL, 15% CONDUIT_UPLOAD
	var r_roll: float = topo_rng.randf()
	var obj: String = "EXTERMINATION"
	if r_roll >= 0.45 and r_roll < 0.70:
		obj = "SABOTAGE_BEACONS"
	elif r_roll >= 0.70 and r_roll < 0.85:
		obj = "OVERDRIVE_SURVIVAL"
	elif r_roll >= 0.85:
		obj = "CONDUIT_UPLOAD"

	var budget: int = compute_room_encounter_budget(node_idx, stratum_idx, has_overdrive_bet, endless_loop_count)
	var total_enemies: int = maxi(3, int(round(float(budget) / 2.5)))
	var wave_1_count: int = mini(MAX_CONCURRENT_ENEMIES, total_enemies)
	var wave_2_count: int = maxi(0, total_enemies - wave_1_count)

	var exit_count: int = 1 if (node_idx == 3 or node_idx == 6) else (2 if topo_rng.randf() < 0.65 else 3)
	return {
		"node_type": &"COMBAT_ROOM",
		"footprint": fp,
		"objective": obj,
		"encounter_budget": budget,
		"wave_1_enemies": wave_1_count,
		"wave_2_enemies": wave_2_count,
		"rival_vesper_ambush": (node_idx == 6 and stratum_bet_streak >= 2),
		"reward_choices": 2 if has_overdrive_bet else 1,
		"doors": _roll_exits(topo_rng, exit_count)
	}


func _roll_exits(rng: RandomNumberGenerator, count: int) -> Array[Dictionary]:
	# Standard exits are 1-2 Monster Encounter Combat Doors (ARMORY_DOOR / TACTICAL_ITEM_DOOR).
	# Only occasionally spawns a 3rd door: either a 100% Monster-Free SAFE_PIT_STOP_DOOR (Black-Market / Forge)
	# or a 50/50 RANDOM_EVENT_DOOR (which may contain monster ambushes or non-combat anomalies).
	var sockets: Array[String] = ["NORTH_WEST", "NORTH_EAST", "EAST_WING"]
	var out: Array[Dictionary] = [
		{"socket": sockets[0], "category": "ARMORY_DOOR", "has_monsters": true, "bet_locked": false}
	]
	if count >= 2:
		out.append({"socket": sockets[1], "category": "TACTICAL_ITEM_DOOR", "has_monsters": true, "bet_locked": false})
	if count >= 3:
		var is_safe_pitstop: bool = (node_index == 3 or rng.randf() < 0.35)
		out.append({
			"socket": sockets[2],
			"category": "SAFE_PIT_STOP_DOOR" if is_safe_pitstop else "RANDOM_EVENT_DOOR",
			"has_monsters": false if is_safe_pitstop else (rng.randf() < 0.50),
			"bet_locked": false
		})
	return out
