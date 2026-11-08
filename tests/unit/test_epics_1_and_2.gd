extends SceneTree
## Headless Unit Suite for Epic 1 (combat-event-bus) & Epic 2 (player-3c-controller).

const CombatEventBusScript = preload("res://src/core/combat_event_bus.gd")
const EquipmentSchemasScript = preload("res://src/core/schemas/equipment_schemas.gd")
const Player3CLogicScript = preload("res://src/combat/player_3c/player_3c_logic.gd")
const ArenaInteractableLogicScript = preload("res://src/combat/player_3c/arena_interactable_logic.gd")

func _init() -> void:
	var passed: int = 0
	var failed: int = 0

	# --- EPIC 1 STORY 001: 4-Stage Priority Order, Depth<=2 Recursion Guard, 32 Procs Cap & F3 Trace ---
	var bus = CombatEventBusScript.new()
	bus.begin_frame(1)
	var order: Array[int] = []
	bus.subscribe(&"perfect_reload_triggered", &"ui_listener", func(_p: Dictionary) -> void: order.append(400), 400)
	bus.subscribe(&"perfect_reload_triggered", &"relic_listener", func(_p: Dictionary) -> void: order.append(200), 200)
	bus.subscribe(&"perfect_reload_triggered", &"math_listener", func(_p: Dictionary) -> void: order.append(100), 100)
	bus.subscribe(&"perfect_reload_triggered", &"clear_listener", func(_p: Dictionary) -> void: order.append(300), 300)
	bus.emit_combat_event(&"perfect_reload_triggered", {"source_id": &"revolver"})
	if order == [100, 200, 300, 400] and bus.get_trace_log().size() == 1:
		passed += 1
	else:
		failed += 1
		printerr("FAIL: EventBus priority order mismatch: ", order)

	# Test recursion depth cutoff at MAX_RECURSION_DEPTH = 2
	bus.begin_frame(2)
	var loop_state := {"count": 0}
	bus.subscribe(&"chain_zap", &"relic_loop", func(_p: Dictionary) -> void:
		loop_state["count"] = int(loop_state["count"]) + 1
		bus.emit_combat_event(&"chain_zap", {}, true)
	, 200)
	bus.emit_combat_event(&"chain_zap", {}, false)
	if int(loop_state["count"]) == 2:
		passed += 1
	else:
		failed += 1
		printerr("FAIL: Recursion guard did not stop at depth 2! Count: ", loop_state["count"])

	# --- EPIC 1 STORY 002: Equipment Schemas & Invalid Sweet-Spot Clamping ---
	var bad_gun: Dictionary = EquipmentSchemasScript.make_primary_weapon_data({
		"id": "peacemaker",
		"rarity_tier": "LEGENDARY",
		"sweet_spot_start": 0.85,
		"sweet_spot_end": 0.40
	})
	if bad_gun["id"] == &"base:peacemaker" and is_equal_approx(bad_gun["sweet_spot_start"], 0.42) and bad_gun["salvage_chip_value"] == 65:
		passed += 1
	else:
		failed += 1
		printerr("FAIL: Schema clamping or rarity salvage failed: ", bad_gun)

	# --- EPIC 2 STORY 001: Sacrosanct 3C Speed Clamp & Dodge-Graze Siphon (Max 2 Base) ---
	var p3c = Player3CLogicScript.new()
	p3c.passive_speed_bonus = 0.50 # Try exceeding +15% cap
	var max_walk: float = p3c.get_effective_walk_speed()
	p3c.try_start_dodge(Vector2.RIGHT, Vector2.ZERO)
	p3c.update_3c(0.10, Vector2.RIGHT) # At 0.10s -> inside 0.28s I-frame window
	var b1 := {"pos": p3c.pos + Vector2(20, 0), "grazed": false}
	var b2 := {"pos": p3c.pos + Vector2(25, 0), "grazed": false}
	var b3 := {"pos": p3c.pos + Vector2(30, 0), "grazed": false}
	var g_total: float = p3c.try_graze_bullet(b1) + p3c.try_graze_bullet(b2) + p3c.try_graze_bullet(b3)
	p3c.update_3c(0.22, Vector2.RIGHT) # Now at 0.32s -> inside DODGE_RECOVERY (0.28s..0.42s)
	if is_equal_approx(max_walk, 333.5) and is_equal_approx(g_total, 20.0) and p3c.is_in_recovery():
		passed += 1
	else:
		failed += 1
		printerr("FAIL: Player3C speed cap, graze cap, or recovery state failed!")

	# --- EPIC 2 STORY 002: Proximity [E] & Ranged-Hit Tactical Arena Interactables ---
	var arena_it = ArenaInteractableLogicScript.new()
	var cap_data: Dictionary = EquipmentSchemasScript.make_arena_interactable_data({
		"id": "tap_box", "trigger_mode": "PROXIMITY_KEY_E", "effect_type": "OVERCHARGE_CAPACITOR"
	})
	var cryo_data: Dictionary = EquipmentSchemasScript.make_arena_interactable_data({
		"id": "cryo_tank", "trigger_mode": "RANGED_HIT", "effect_type": "CRYO_SLOW_FIELD"
	})
	arena_it.spawn_interactable(cap_data, Vector2(400, 400))
	arena_it.spawn_interactable(cryo_data, Vector2(700, 250))
	var res_e: Dictionary = arena_it.try_trigger_proximity_e(Vector2(410, 400), Vector2.UP)
	var res_hit: Dictionary = arena_it.try_trigger_ranged_hit(Vector2(705, 250), Vector2.UP)
	if res_e.get("overcharge_grant", 0.0) == 22.0 and res_hit.get("slow_mult", 1.0) == 0.50:
		passed += 1
	else:
		failed += 1
		printerr("FAIL: ArenaInteractables proximity/ranged trigger failed!")

	print("EPICS 1 & 2 UNIT SUITE COMPLETE -> Passed: %d | Failed: %d" % [passed, failed])
	quit(0 if failed == 0 else 1)
