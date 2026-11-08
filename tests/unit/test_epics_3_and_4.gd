extends SceneTree
## Headless Unit Suite for Epic 3 (bullet-hell-damage-system) & Epic 4 (dual-gun-overcharge-engine).

const BulletPoolLogicScript = preload("res://src/combat/bullet_pool/bullet_pool_logic.gd")
const AegisAndDamageLogicScript = preload("res://src/combat/bullet_pool/aegis_and_damage_logic.gd")
const OverchargeEngineLogicScript = preload("res://src/combat/weapons/overcharge_engine_logic.gd")
const ActiveReloadControllerScript = preload("res://src/combat/weapons/active_reload_controller.gd")
const GunPeacemakerScript = preload("res://src/content/weapons/gun_peacemaker.gd")
const GunVectorSMGScript = preload("res://src/content/weapons/gun_vector_smg.gd")
const GunBailiffShotgunScript = preload("res://src/content/weapons/gun_bailiff_shotgun.gd")

func _init() -> void:
	var passed: int = 0
	var failed: int = 0

	# --- EPIC 3 STORY 001: 800-Slot Pool, Synergy Coalescing (>24 -> 24 with multiplied DMG) & Non-Blocking Hitstop ---
	var pool = BulletPoolLogicScript.new()
	var burst_reqs: Array[Dictionary] = []
	for i in range(48):
		burst_reqs.append({"pos": Vector2.ZERO, "vel": Vector2.RIGHT * 500.0, "dmg": 10.0, "team": "player"})
	var spawned_ids: Array[int] = pool.spawn_player_burst(burst_reqs)
	pool.trigger_hitstop(0.05)
	var p_delta: float = pool.get_player_delta(0.016)
	var w_delta: float = pool.get_world_delta(0.016)
	if spawned_ids.size() == 24 and is_equal_approx(pool.slots[spawned_ids[0]]["dmg"], 20.0) and is_equal_approx(p_delta, 0.016) and w_delta < 0.004:
		passed += 1
	else:
		failed += 1
		printerr("FAIL: BulletPool coalescing or non-blocking hitstop failed!")

	# --- EPIC 3 STORY 002: 3-Tier Recoil/Knockback & 3-Pip Overcharge Aegis Shield vs SHIELD_PIERCING ---
	var aegis = AegisAndDamageLogicScript.new()
	aegis.reset_for_new_run(6, 1)
	# Normal hit absorbed by shield -> preserves boss_hitless_eligible!
	var hit_norm: Dictionary = aegis.apply_player_hit(1, false)
	aegis.tick_timers(1.5)
	# Entering a new room does NOT auto-refill shield
	aegis.on_enter_new_room(false)
	var shield_after_room: int = aegis.aegis_shield
	# Earn 3 Pips: 1 Heavy cast + 1 Interrupt + 3 Perfect Reloads -> reconstructs shield!
	aegis.award_aegis_pip()
	aegis.award_aegis_pip()
	aegis.record_combat_perfect_reload(false)
	aegis.record_combat_perfect_reload(false)
	var rebuilt: bool = aegis.record_combat_perfect_reload(false)
	# Now test SHIELD_PIERCING attack -> bypasses shield and damages HP directly!
	aegis.tick_timers(1.5)
	var hit_pierce: Dictionary = aegis.apply_player_hit(1, true)
	var recoil_med: float = AegisAndDamageLogicScript.compute_shooter_recoil_slide_px(false, true, 65.0, false)
	if hit_norm["shield_absorbed"] and hit_norm["boss_hitless_eligible"] and shield_after_room == 0 and rebuilt and aegis.aegis_shield == 1 and aegis.hp == 5 and not hit_pierce["boss_hitless_eligible"] and is_equal_approx(recoil_med, 16.0):
		passed += 1
	else:
		failed += 1
		printerr("FAIL: Aegis 3-Pip reconstruction or SHIELD_PIERCING resolution failed!")

	# --- EPIC 4 STORY 001: 72-100⚡ Room Overcharge Ledger, Zero Out-of-Combat Farming & 45/65/90⚡ Heavy ---
	var oc = OverchargeEngineLogicScript.new()
	oc.reset_for_new_room(0.0)
	for i in range(24):
		oc.on_primary_firing_hit(false)
	for i in range(3):
		oc.on_primary_firing_hit(true)
	for i in range(2):
		oc.on_perfect_reload()
	for i in range(2):
		oc.on_dodge_graze()
	oc.on_dynamo_core_proc(22.0)
	var total_room_oc: float = oc.overcharge
	var cast_ok: bool = oc.try_cast_heavy(65.0, 3.5)
	var cd_blocked: bool = not oc.try_cast_heavy(45.0, 2.5)
	# Out-of-combat farming check
	oc.room_cleared = true
	var farmed_after_clear: float = oc.on_perfect_reload()
	if is_equal_approx(total_room_oc, 82.0) and cast_ok and cd_blocked and is_equal_approx(farmed_after_clear, 0.0):
		passed += 1
	else:
		failed += 1
		printerr("FAIL: Overcharge ledger, heavy cooldown, or anti-farming gate failed! OC=", total_room_oc)

	# --- EPIC 4 STORY 002: Self-Contained Weapon Reload Profiles & Signature Buffs ---
	var reloader = ActiveReloadControllerScript.new()
	var revolver = GunPeacemakerScript.new()
	var smg = GunVectorSMGScript.new()
	var shotgun = GunBailiffShotgunScript.new()

	# Test SMG early sweet spot [0.22..0.40]
	reloader.equip_weapon_profile(smg)
	reloader.ammo = 2
	reloader.start_reload(smg)
	reloader.reload_progress = 0.30
	var smg_res: Dictionary = reloader.attempt_active_reload(smg)

	# Test Shotgun late sweet spot [0.65..0.81] -> grants +3 pellets (5 + 3 = 8 pellets)
	reloader.equip_weapon_profile(shotgun)
	reloader.ammo = 1
	reloader.start_reload(shotgun)
	reloader.reload_progress = 0.72
	var sg_res: Dictionary = reloader.attempt_active_reload(shotgun)
	var sg_shots: Array[Dictionary] = shotgun.build_shot_requests(Vector2.ZERO, Vector2.RIGHT, false, true)

	# Test Revolver missed sweet spot -> JAMMED_RELOAD
	reloader.equip_weapon_profile(revolver)
	reloader.ammo = 1
	reloader.start_reload(revolver)
	reloader.reload_progress = 0.15
	var rev_jam: Dictionary = reloader.attempt_active_reload(revolver)

	if smg_res["outcome"] == &"PERFECT_RELOAD" and sg_res["outcome"] == &"PERFECT_RELOAD" and sg_shots.size() == 8 and rev_jam["outcome"] == &"JAMMED_RELOAD" and reloader.reload_jammed:
		passed += 1
	else:
		failed += 1
		printerr("FAIL: Weapon reload profiles or signature buffs failed!")

	print("EPICS 3 & 4 UNIT SUITE COMPLETE -> Passed: %d | Failed: %d" % [passed, failed])
	quit(0 if failed == 0 else 1)
