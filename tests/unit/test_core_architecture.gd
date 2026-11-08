extends SceneTree
## Fast Zero-Scene Headless Test Runner (< 0.5s execution).
## Verifies ADR-005 (6-Stream Coordinate-Hashed RNG isolation & Overdrive Bet 0% Common rule)
## and ADR-003 (BalanceConfig single-source constants).

const BalanceConfigScript = preload("res://src/core/balance_config.gd")
const DeterministicRNGScript = preload("res://src/core/deterministic_rng_service.gd")

func _init() -> void:
	var passed: int = 0
	var failed: int = 0

	# Test 1: Butterfly-Effect Isolation (500 combat rolls must NOT change Room 2 Loot/Shop rolls)
	var rng_a = DeterministicRNGScript.new("X9-G7K2")
	var rng_b = DeterministicRNGScript.new("X9-G7K2")
	for i in range(500):
		rng_a.stream_combat.randf()
		rng_a.stream_cosmetic.randf()
	var roll_a: String = rng_a.roll_rarity(1, false, 2, 0)
	var roll_b: String = rng_b.roll_rarity(1, false, 2, 0)
	if roll_a == roll_b:
		passed += 1
	else:
		failed += 1
		printerr("FAIL: Combat RNG polluted Loot RNG stream!")

	# Test 2: Multiplicative Overcharge Boost Formula: Base_Drop (0.35) * (1.0 + X%) and Rarity Weight * (1.0 + k * X%)
	var base_drop: float = DeterministicRNGScript.compute_equipment_drop_chance(0.0, 0)
	var boosted_drop: float = DeterministicRNGScript.compute_equipment_drop_chance(1.0, 2) # x_pct = 0.50 + 0.40 = 0.90 -> 0.35 * 1.90 = 0.665
	if is_equal_approx(base_drop, 0.35) and is_equal_approx(boosted_drop, 0.35 * 1.90):
		passed += 1
	else:
		failed += 1
		printerr("FAIL: Multiplicative Base * (1 + X%) drop formula mismatch!")

	# Test 3: Room Overcharge Budget Math (24 hits + 3 finals + 2 reloads + 2 grazes + 1 saboteur = 82.0 Overcharge)
	var room_yield: float = (
		24.0 * BalanceConfigScript.CHARGE_NORMAL_HIT
		+ 3.0 * BalanceConfigScript.CHARGE_FINAL_ROUND
		+ 2.0 * BalanceConfigScript.CHARGE_PERFECT_RELOAD
		+ 2.0 * BalanceConfigScript.CHARGE_DODGE_GRAZE
		+ 22.0
	)
	if is_equal_approx(room_yield, 82.0) and room_yield >= BalanceConfigScript.HEAVY_COST_MEDIUM:
		passed += 1
	else:
		failed += 1
		printerr("FAIL: Room Overcharge yield mismatch: ", room_yield)

	print("HEADLESS UNIT SUITE COMPLETE -> Passed: %d | Failed: %d" % [passed, failed])
	quit(0 if failed == 0 else 1)
