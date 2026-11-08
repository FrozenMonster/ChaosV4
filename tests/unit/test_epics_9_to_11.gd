extends SceneTree
## Headless Unit Suite for Epics 9-11 (Micro-HUD Wayfinder, Audio Sidechain/Pitch Ladders, ThemeSkinCatalog & Save/MOD Registry).

const MicroHUDLogicScript = preload("res://src/ui/micro_hud_and_wayfinder_logic.gd")
const AudioJuiceLogicScript = preload("res://src/audio/audio_juice_logic.gd")
const SaveAndSkinCatalogScript = preload("res://src/persistence/save_and_skin_catalog.gd")

func _init() -> void:
	var passed: int = 0
	var failed: int = 0

	# --- EPIC 9: Off-Screen Wayfinder Edge Clamping (1244, 360) & Top-Wall Reload Bar Flip ---
	var wf_pos: Vector2 = MicroHUDLogicScript.compute_wayfinder_screen_pos(Vector2(1800.0, 360.0), Vector2(640.0, 360.0))
	var top_bar_ofs: Vector2 = MicroHUDLogicScript.get_reload_bar_offset(Vector2(640.0, 100.0))
	var crit_scale_t0: float = MicroHUDLogicScript.compute_popup_render_scale(true, 0.0)
	if is_equal_approx(wf_pos.x, 1244.0) and is_equal_approx(wf_pos.y, 360.0) and is_equal_approx(top_bar_ofs.y, 28.0) and is_equal_approx(crit_scale_t0, 1.45):
		passed += 1
	else:
		failed += 1
		printerr("FAIL: MicroHUD wayfinder clamping or top-wall flip failed! wf=", wf_pos)

	# --- EPIC 10: 4-Bus Sidechain Ducking (-4.0 dB), Graze Pitch Ladder & 18px Shake Hard Cap ---
	var audio = AudioJuiceLogicScript.new()
	audio.trigger_critical_cue_ducking()
	var duck_active_db: float = audio.get_secondary_bus_ducking_db()
	audio.tick_audio_and_juice(0.25)
	var duck_recovered_db: float = audio.get_secondary_bus_ducking_db()
	var p1: float = AudioJuiceLogicScript.compute_streak_pitch(1, 0.12)
	var p3: float = AudioJuiceLogicScript.compute_streak_pitch(3, 0.12)
	audio.apply_camera_impulse(Vector2.RIGHT, 16.0, 14.0)
	var cam_ofs: Vector2 = audio.compute_final_camera_offset(Vector2.ONE)
	if is_equal_approx(duck_active_db, -4.0) and is_equal_approx(duck_recovered_db, 0.0) and is_equal_approx(p1, 1.00) and is_equal_approx(p3, 1.24) and cam_ofs.length() <= 18.01:
		passed += 1
	else:
		failed += 1
		printerr("FAIL: Audio ducking, pitch ladder, or 18px camera shake cap failed!")

	# --- EPIC 11A: ThemeSkinCatalog Instant World-Lore Re-Skinning & MOD Namespace Isolation ---
	var catalog = SaveAndSkinCatalogScript.new()
	catalog.apply_skin_override_table({&"base:currency_in_run": "灵石", &"base:npc_specialist_merchant": "炼器老祖"})
	var mod_key: StringName = catalog.register_content_entry("mod_laser_cat", "peacemaker", {"dmg": 99})
	var base_key: StringName = catalog.register_content_entry("base", "peacemaker", {"dmg": 18})
	if catalog.get_skin_text(&"base:currency_in_run") == "灵石" and mod_key == &"mod_laser_cat:peacemaker" and catalog.registered_content[base_key]["dmg"] == 18:
		passed += 1
	else:
		failed += 1
		printerr("FAIL: ThemeSkinCatalog re-skinning or MOD namespace isolation failed!")

	# --- EPIC 11B: Run Sparks Formula (133 Sparks) & Atomic Save Corruption .bak Fallback ---
	var sparks: int = SaveAndSkinCatalogScript.compute_run_sparks_earned(15, 3, 2, 0, 2)
	var good_bak: Dictionary = SaveAndSkinCatalogScript.pack_save_envelope({"sparks": 133, "vesper_unlocked": true})
	var corrupted_primary := {"sha256": "bad_hash", "payload_json": "{corrupted_bytes"}
	var load_res: Dictionary = SaveAndSkinCatalogScript.unpack_and_verify_save_envelope(corrupted_primary, good_bak)
	if sparks == 133 and load_res["valid"] and load_res["restored_from_backup"] and int(load_res["data"]["sparks"]) == 133:
		passed += 1
	else:
		failed += 1
		printerr("FAIL: Run Sparks math or .bak corruption recovery failed! sparks=", sparks)

	print("EPICS 9 TO 11 UNIT SUITE COMPLETE -> Passed: %d | Failed: %d" % [passed, failed])
	quit(0 if failed == 0 else 1)
