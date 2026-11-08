extends SceneTree
## Headless Unit Suite for Feature Epics 5-8 (StatPipeline, Loadout, Enemy/Boss UID, FloorRouter & PitStop/Rivals).

const StatPipelineScript = preload("res://src/core/stat_pipeline.gd")
const LoadoutAndRelicLogicScript = preload("res://src/features/loadout/loadout_and_relic_logic.gd")
const EnemyAndBossLogicScript = preload("res://src/combat/enemies/enemy_and_boss_logic.gd")
const FloorRouterLogicScript = preload("res://src/progression/floor_router/floor_router_logic.gd")
const PitStopAndRivalLogicScript = preload("res://src/progression/pit_stop/pit_stop_and_rival_logic.gd")

func _init() -> void:
	var passed: int = 0
	var failed: int = 0

	# --- EPIC 5A: 4-Stage Commutative StatPipeline & NaN Fault Isolation ---
	var mods_abc: Array[Dictionary] = [
		{"stat": "damage", "stage": "flat", "value": 4.0},
		{"stat": "damage", "stage": "pct_add", "value": 0.40},
		{"stat": "damage", "stage": "pct_add", "value": 0.60},
		{"stat": "damage", "stage": "indep_mult", "value": 2.5},
		{"stat": "damage", "stage": "pct_add", "value": NAN} # Faulty MOD script NaN!
	]
	var mods_cba: Array[Dictionary] = [mods_abc[3], mods_abc[2], mods_abc[0], mods_abc[1]]
	var val_1: float = StatPipelineScript.evaluate_stat("damage", 18.0, mods_abc)
	var val_2: float = StatPipelineScript.evaluate_stat("damage", 18.0, mods_cba)
	# Also verify dodge_duration is 100% locked at 0.42s even if a mod tries to change it!
	var locked_roll: float = StatPipelineScript.evaluate_stat("dodge_duration", 0.42, [{"stat": "dodge_duration", "stage": "pct_add", "value": 0.50}])
	if is_equal_approx(val_1, val_2) and is_equal_approx(val_1, 110.0) and is_equal_approx(locked_roll, 0.42):
		passed += 1
	else:
		failed += 1
		printerr("FAIL: StatPipeline commutativity or dodge lock failed! v1=", val_1, " v2=", val_2)

	# --- EPIC 5B: 7-Slot Loadout, Exclusivity Group Mutex Filter & Salvage with Magnet (+50%) ---
	var loadout = LoadoutAndRelicLogicScript.new()
	loadout.try_pickup_passive_relic({"id": "bounty_audit_magnet", "rarity_tier": "LEGENDARY"})
	loadout.try_pickup_passive_relic({"id": "super_capacitor_coil", "rarity_tier": "EPIC", "exclusivity_group": "max_overcharge_rule"})
	loadout.try_pickup_passive_relic({"id": "tesla_mag_well", "rarity_tier": "RARE"})
	# Pool filter must exclude both already-equipped IDs and conflicting exclusivity_group!
	var candidates: Array[Dictionary] = [
		{"id": &"base:glass_reactor", "exclusivity_group": &"max_overcharge_rule"},
		{"id": &"base:omega_firing_pin", "exclusivity_group": &""}
	]
	var filtered: Array[Dictionary] = loadout.filter_eligible_relic_pool(candidates)
	# 4th pickup triggers AWAITING_PASSIVE_SWAP; swapping RARE slot (25 base * 1.5 magnet = 38 Chips!)
	var pickup_4: Dictionary = loadout.try_pickup_passive_relic({"id": "omega_firing_pin", "rarity_tier": "EPIC"})
	var swap_res: Dictionary = loadout.swap_passive_slot(2)
	if filtered.size() == 1 and pickup_4["status"] == &"AWAITING_PASSIVE_SWAP" and swap_res["chips_gained"] == 38:
		passed += 1
	else:
		failed += 1
		printerr("FAIL: Loadout mutex filter or magnet salvage failed! Swap=", swap_res)

	# --- EPIC 6: 3-Tier AI (Zero Interrupt on Fodder), BossPartNode Break & Entity UID Crash Safety ---
	var ai = EnemyAndBossLogicScript.new()
	var fodder_uid: int = ai.spawn_enemy({"id": "burst_bot", "tier": 1, "base_hp": 85.0}, 1, 0, false)
	var boss_uid: int = ai.spawn_enemy({
		"id": "quota_crusher", "tier": 3, "base_hp": 2000.0,
		"boss_parts": [{"part_id": "left_missile_pod", "hp": 100.0, "disables_attack_id": "homing_salvo"}]
	}, 1, 0, false)
	var fodder_windup_ok: bool = ai.start_weakpoint_windup(fodder_uid) # Must be FALSE on Tier 1 Fodder!
	var part_res: Dictionary = ai.apply_damage(boss_uid, 120.0, true, &"left_missile_pod")
	# Kill fodder and verify get_alive(fodder_uid) returns empty dict safely without crash
	ai.apply_damage(fodder_uid, 500.0, true)
	var dead_lookup: Dictionary = ai.get_alive(fodder_uid)
	if not fodder_windup_ok and part_res["part_broken"] == &"left_missile_pod" and is_equal_approx(part_res["overcharge_award"], 22.0) and dead_lookup.is_empty():
		passed += 1
	else:
		failed += 1
		printerr("FAIL: Enemy/Boss UID handle, fodder interrupt block, or part break failed!")

	# --- EPIC 7: 7-Node FloorRouter, Non-Repeating Footprints, Wave Cap (<=7) & Vesper Ambush on 2x Bet ---
	var router = FloorRouterLogicScript.new()
	var r1: Dictionary = router.generate_room_node(3, 5, true, "STANDARD_CHAMBER")
	var r6: Dictionary = router.generate_room_node(3, 6, true, r1["footprint"])
	if r1["footprint"] != "STANDARD_CHAMBER" and r6["footprint"] != r1["footprint"] and r6["wave_1_enemies"] <= 7 and r6["rival_vesper_ambush"]:
		passed += 1
	else:
		failed += 1
		printerr("FAIL: FloorRouter non-repeating footprint, wave cap, or Vesper ambush failed!")

	# --- EPIC 8: Pit-Stop Strict +1 HP Heal, Coordinate-Hashed Blind Box & Rival->Playable Lifecycle ---
	var pit = PitStopAndRivalLogicScript.new()
	var healed_hp: int = pit.apply_strict_pit_stop_heal(3, 6)
	var box_1: Dictionary = pit.open_mystery_contraband_box(1, 4, 0)
	var box_1_reload: Dictionary = pit.open_mystery_contraband_box(1, 4, 0) # Simulate Alt+F4 reload!
	pit.advance_rival_state(&"vesper") # -> AMBUSH_HIDDEN_BOSS
	pit.advance_rival_state(&"vesper", true, false) # -> SHIP_ALLY
	var final_state: StringName = pit.advance_rival_state(&"vesper", false, true) # -> PLAYABLE_GUNBOY
	if healed_hp == 4 and box_1 == box_1_reload and final_state == &"PLAYABLE_GUNBOY":
		passed += 1
	else:
		failed += 1
		printerr("FAIL: PitStop strict +1 heal, coordinate-hashed Blind Box, or Rival lifecycle failed!")

	print("EPICS 5 TO 8 UNIT SUITE COMPLETE -> Passed: %d | Failed: %d" % [passed, failed])
	quit(0 if failed == 0 else 1)
