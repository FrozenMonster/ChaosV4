# PROTOTYPE - NOT FOR PRODUCTION
extends Node2D
## Stage 1 Concept Prototype: CHAMBER OVERDRIVE
## Validates:
## 1) 3C Movement, Committed Dodge Roll (I-frames + Outer Graze Ring + Recovery), Table Cover Flip
## 2) Active Reload (Sweet-Spot Slider) & Final-Round Triggers
## 3) Two-Tier Overcharge Economy (Tier 1 Risk-Weighted Base Actions + Tier 2 Dynamo Cores -> Cost-Tiered Heavy Weapons)
## 4) 3 Door Categories (1. Armory [Primary/Heavy/Dynamo], 2. Items [Active Cap 1 / Passive Cap 3], 3. Random Event [Currency/HP/Energy/Monster]) + Overdrive Bet

const ARENA_RECT := Rect2(80.0, 90.0, 1120.0, 560.0)

# --- Player 3C Constants (Sacred 3C Lock) ---
const BASE_MOVE_SPEED: float = 290.0
const DODGE_DURATION: float = 0.42
const DODGE_IFRAME_END: float = 0.28
const DODGE_SPEED: float = 640.0
const PLAYER_RADIUS: float = 14.0
const GRAZE_RADIUS: float = 42.0

# --- Tier 1 Base Action Overcharge Values (Weighted by Difficulty/Risk) ---
const CHARGE_NORMAL_HIT: float = 1.0
const CHARGE_FINAL_ROUND_HIT: float = 8.0
const CHARGE_PERFECT_RELOAD: float = 14.0
const CHARGE_DODGE_GRAZE: float = 20.0
const CHARGE_WEAKPOINT_INTERRUPT: float = 35.0

# --- Player State ---
var player_pos: Vector2 = Vector2(640.0, 520.0)
var player_vel: Vector2 = Vector2.ZERO
var last_move_dir: Vector2 = Vector2.UP
var hp: int = 6
var max_hp: int = 6
var armor: int = 1
var scrap_shells: int = 45
var overcharge: float = 40.0
var max_overcharge: float = 100.0
var invuln_timer: float = 0.0

# Dodge state
var is_dodging: bool = false
var dodge_timer: float = 0.0
var dodge_dir: Vector2 = Vector2.ZERO
var dodge_grazed_count: int = 0

# --- Loadout Schema (1 Primary + 1 Heavy + 1 Dynamo Core | 1 Active + Max 3 Passives) ---
var primary_weapons: Array[Dictionary] = [
	{
		"name": "Peacemaker Revolver",
		"mag_size": 6,
		"fire_interval": 0.20,
		"damage": 18.0,
		"bullet_speed": 820.0,
		"reload_time": 1.15,
		"sweet_start": 0.42,
		"sweet_end": 0.64,
		"final_round_desc": "Final Round: 2.5x Piercing High-Explosive Slug"
	},
	{
		"name": "Vector Twin-SMG",
		"mag_size": 14,
		"fire_interval": 0.09,
		"damage": 9.0,
		"bullet_speed": 760.0,
		"reload_time": 1.05,
		"sweet_start": 0.48,
		"sweet_end": 0.68,
		"final_round_desc": "Final Round: Triple Shock-Fan Burst"
	}
]
var primary_idx: int = 0

var heavy_weapons: Array[Dictionary] = [
	{
		"name": "Swarm Micro-Missiles [Light]",
		"cost": 30.0,
		"type": "swarm",
		"desc": "Cost 30: Fires 5 homing missiles"
	},
	{
		"name": "Railgun Piercer [Medium]",
		"cost": 50.0,
		"type": "rail",
		"desc": "Cost 50: Instant hyper-beam piercing all enemies"
	},
	{
		"name": "Singularity Black Hole [Ultimate]",
		"cost": 90.0,
		"type": "black_hole",
		"desc": "Cost 90: Pulls enemies & devours enemy bullets for 3.2s"
	}
]
var heavy_idx: int = 0
var using_heavy: bool = false

var dynamo_cores: Array[Dictionary] = [
	{
		"id": "kill_chain",
		"name": "Rampage Dynamo (Easy: +12 on Multi-Kill)",
		"bonus": 12.0,
		"desc": "Kill within 3s of previous kill -> +12 Overcharge"
	},
	{
		"id": "bullet_shatter",
		"name": "Aegis Shatter Dynamo (Med: +28 on 3+ Bullets Cleared)",
		"bonus": 28.0,
		"desc": "Clear >=3 enemy bullets with Perfect Reload / Blank -> +28 Overcharge"
	},
	{
		"id": "barrel_kick",
		"name": "Demolition Dynamo (Hard: +40 on Hazard Kill/Hit)",
		"bonus": 40.0,
		"desc": "Detonate explosive barrel on enemy -> +40 Overcharge"
	}
]
var dynamo_idx: int = 0
var last_kill_time: float = -10.0

var active_item: Dictionary = {
	"name": "EMP Blank Pulse",
	"cooldown": 8.0,
	"timer": 0.0,
	"desc": "[Space/Shift or C] Clears nearby bullets & stuns"
}

const PASSIVE_CAP: int = 3
var passive_items: Array[Dictionary] = [
	{"id": "shock_reload", "name": "Tesla Mag-Well", "desc": "Perfect Reload zaps nearby enemies & clears close bullets"},
	{"id": "fleet_step", "name": "Kinetic Boots", "desc": "+12% Move Speed & wider Graze ring"}
]
var pending_passive_offer: Dictionary = {}

# --- Active Reload & Firing State ---
var ammo: int = 6
var fire_cd: float = 0.0
var is_reloading: bool = false
var reload_progress: float = 0.0
var reload_attempted: bool = false
var reload_jammed: bool = false
var perfect_reload_buff_timer: float = 0.0

# --- Pooled Entities & Arena Objects ---
var bullets: Array[Dictionary] = []
var enemies: Array[Dictionary] = []
var cover_tables: Array[Dictionary] = []
var barrels: Array[Dictionary] = []
var black_holes: Array[Dictionary] = []
var floating_texts: Array[Dictionary] = []
var doors: Array[Dictionary] = []

# --- Room & Progression State ---
var room_number: int = 1
var room_cleared: bool = false
var active_overdrive_bet: bool = false
var current_event_popup: String = ""
var screen_shake: float = 0.0
var hitstop_timer: float = 0.0
var elapsed_time: float = 0.0


func _ready() -> void:
	ammo = _cur_primary()["mag_size"]
	_setup_room(1, "armory", false)


func _cur_primary() -> Dictionary:
	return primary_weapons[primary_idx]


func _cur_heavy() -> Dictionary:
	return heavy_weapons[heavy_idx]


func _cur_dynamo() -> Dictionary:
	return dynamo_cores[dynamo_idx]


func _has_passive(pid: String) -> bool:
	for p in passive_items:
		if p["id"] == pid:
			return true
	return false


func _process(delta: float) -> void:
	elapsed_time += delta
	if hitstop_timer > 0.0:
		hitstop_timer -= delta
		queue_redraw()
		return

	if screen_shake > 0.0:
		screen_shake = maxf(0.0, screen_shake - delta * 28.0)
	if invuln_timer > 0.0:
		invuln_timer = maxf(0.0, invuln_timer - delta)
	if perfect_reload_buff_timer > 0.0:
		perfect_reload_buff_timer = maxf(0.0, perfect_reload_buff_timer - delta)
	if active_item["timer"] > 0.0:
		active_item["timer"] = maxf(0.0, active_item["timer"] - delta)

	_handle_hotkeys()
	_update_player(delta)
	_update_weapons(delta)
	_update_enemies(delta)
	_update_black_holes(delta)
	_update_bullets(delta)
	_update_floating_texts(delta)
	_check_room_state()
	queue_redraw()


func _handle_hotkeys() -> void:
	# Quick prototype switching to test all weapons/dynamos anytime
	if Input.is_key_pressed(KEY_1):
		dynamo_idx = 0
	elif Input.is_key_pressed(KEY_2):
		dynamo_idx = 1
	elif Input.is_key_pressed(KEY_3):
		dynamo_idx = 2

	if Input.is_action_just_pressed("ui_focus_next") or Input.is_key_pressed(KEY_TAB):
		pass


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_Q:
				using_heavy = not using_heavy
				_spawn_text(player_pos + Vector2(0, -28), "SWAP -> " + (_cur_heavy()["name"] if using_heavy else _cur_primary()["name"]), Color(0.4, 0.95, 1.0))
			KEY_Z:
				primary_idx = (primary_idx + 1) % primary_weapons.size()
				ammo = _cur_primary()["mag_size"]
				is_reloading = false
				_spawn_text(player_pos + Vector2(0, -28), "Primary: " + _cur_primary()["name"], Color.WHITE)
			KEY_X:
				heavy_idx = (heavy_idx + 1) % heavy_weapons.size()
				_spawn_text(player_pos + Vector2(0, -28), "Heavy: " + _cur_heavy()["name"], Color(1.0, 0.85, 0.2))
			KEY_C:
				_trigger_active_item()
			KEY_R:
				_on_reload_pressed()
			KEY_E:
				_on_interact_pressed()
			KEY_F:
				_on_bet_pressed()
			KEY_7:
				_resolve_passive_swap(0)
			KEY_8:
				_resolve_passive_swap(1)
			KEY_9:
				_resolve_passive_swap(2)
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_try_start_dodge()


func _update_player(delta: float) -> void:
	var move_input := Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		move_input.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		move_input.y += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		move_input.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		move_input.x += 1.0
	if move_input.length_squared() > 0.0:
		move_input = move_input.normalized()
		last_move_dir = move_input

	if Input.is_key_pressed(KEY_SPACE) and not is_dodging:
		_try_start_dodge()

	if is_dodging:
		dodge_timer += delta
		var speed_factor: float = 1.0 if dodge_timer < DODGE_IFRAME_END else 0.42
		player_vel = dodge_dir * DODGE_SPEED * speed_factor
		if dodge_timer >= DODGE_DURATION:
			is_dodging = false
	else:
		var spd := BASE_MOVE_SPEED * (1.12 if _has_passive("fleet_step") else 1.0)
		player_vel = move_input * spd

	player_pos += player_vel * delta
	player_pos.x = clampf(player_pos.x, ARENA_RECT.position.x + PLAYER_RADIUS, ARENA_RECT.end.x - PLAYER_RADIUS)
	player_pos.y = clampf(player_pos.y, ARENA_RECT.position.y + PLAYER_RADIUS, ARENA_RECT.end.y - PLAYER_RADIUS)

	# Keep player out of solid flipped tables
	for t in cover_tables:
		if t["hp"] > 0.0:
			var rect: Rect2 = t["rect"]
			if rect.grow(PLAYER_RADIUS * 0.8).has_point(player_pos):
				var center := rect.get_center()
				var push := (player_pos - center).normalized()
				player_pos += push * 4.0


func _try_start_dodge() -> void:
	if is_dodging:
		return
	is_dodging = true
	dodge_timer = 0.0
	dodge_grazed_count = 0
	var aim_dir := (get_global_mouse_position() - player_pos).normalized()
	dodge_dir = last_move_dir if last_move_dir.length_squared() > 0.01 else aim_dir


func _update_weapons(delta: float) -> void:
	if fire_cd > 0.0:
		fire_cd -= delta

	var p_gun := _cur_primary()
	if is_reloading:
		var r_speed: float = 1.0 / p_gun["reload_time"]
		if reload_jammed:
			r_speed *= 0.68
		reload_progress += delta * r_speed
		if reload_progress >= 1.0:
			is_reloading = false
			reload_progress = 0.0
			ammo = p_gun["mag_size"]
			_spawn_text(player_pos + Vector2(0, -24), "RELOADED", Color(0.8, 0.85, 0.9))

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if using_heavy:
			_try_fire_heavy()
		else:
			_try_fire_primary()


func _on_reload_pressed() -> void:
	var p_gun := _cur_primary()
	if not is_reloading:
		if ammo >= p_gun["mag_size"]:
			return
		is_reloading = true
		reload_progress = 0.0
		reload_attempted = false
		reload_jammed = false
		return

	# Active Reload timing check!
	if reload_attempted:
		return
	reload_attempted = true
	var s_start: float = p_gun["sweet_start"]
	var s_end: float = p_gun["sweet_end"]
	if _has_passive("wide_sweet"):
		s_end += 0.08

	if reload_progress >= s_start and reload_progress <= s_end:
		# PERFECT RELOAD!
		is_reloading = false
		reload_progress = 0.0
		ammo = p_gun["mag_size"]
		perfect_reload_buff_timer = 2.5
		_add_overcharge(CHARGE_PERFECT_RELOAD, "PERFECT RELOAD +14⚡")
		screen_shake = 6.0
		_trigger_perfect_reload_effects()
	else:
		# Missed sweet spot -> slight jam penalty
		reload_jammed = true
		_spawn_text(player_pos + Vector2(0, -32), "JAMMED! (Missed Window)", Color(1.0, 0.35, 0.3))


func _trigger_perfect_reload_effects() -> void:
	var cleared: int = 0
	var shock_radius: float = 135.0 if _has_passive("shock_reload") else 85.0
	for b in bullets:
		if b["active"] and b["team"] == "enemy" and b["pos"].distance_to(player_pos) <= shock_radius:
			b["active"] = false
			cleared += 1
	if _has_passive("shock_reload"):
		for e in enemies:
			if e["hp"] > 0.0 and e["pos"].distance_to(player_pos) <= shock_radius + 30.0:
				_damage_enemy(e, 26.0, false)
	if cleared >= 3 and _cur_dynamo()["id"] == "bullet_shatter":
		_add_overcharge(_cur_dynamo()["bonus"], "AEGIS SHATTER DYNAMO +28⚡")


func _try_fire_primary() -> void:
	if is_reloading or fire_cd > 0.0:
		return
	if ammo <= 0:
		is_reloading = true
		reload_progress = 0.0
		reload_attempted = false
		reload_jammed = false
		return

	var p_gun := _cur_primary()
	var is_final_round: bool = (ammo == 1)
	ammo -= 1
	fire_cd = p_gun["fire_interval"]
	var aim_dir := (get_global_mouse_position() - player_pos).normalized()

	var dmg_mult: float = 1.25 if perfect_reload_buff_timer > 0.0 else 1.0
	if is_final_round and _has_passive("final_amp"):
		dmg_mult *= 1.6

	if is_final_round:
		screen_shake = 7.5
		_spawn_text(player_pos + Vector2(0, -34), "FINAL ROUND!", Color(1.0, 0.78, 0.2))
		if primary_idx == 0:
			# Piercing high-explosive slug
			_spawn_bullet(player_pos + aim_dir * 16.0, aim_dir * 960.0, p_gun["damage"] * 2.5 * dmg_mult, "player", 9.0, true, true)
		else:
			# Triple shock-fan burst
			for angle_deg in [-14.0, 0.0, 14.0]:
				var dir := aim_dir.rotated(deg_to_rad(angle_deg))
				_spawn_bullet(player_pos + dir * 16.0, dir * 860.0, p_gun["damage"] * 1.9 * dmg_mult, "player", 7.0, true, true)
		# Auto start reload bar after Final Round
		is_reloading = true
		reload_progress = 0.0
		reload_attempted = false
		reload_jammed = false
	else:
		screen_shake = maxf(screen_shake, 2.0)
		var spread := randf_range(-0.04, 0.04)
		var dir := aim_dir.rotated(spread)
		_spawn_bullet(player_pos + dir * 16.0, dir * p_gun["bullet_speed"], p_gun["damage"] * dmg_mult, "player", 5.0, false, false)


func _try_fire_heavy() -> void:
	if fire_cd > 0.0:
		return
	var h_gun := _cur_heavy()
	var cost: float = h_gun["cost"]
	if overcharge < cost:
		_spawn_text(player_pos + Vector2(0, -30), "NEED %d⚡ OVERCHARGE!" % int(cost), Color(1.0, 0.3, 0.3))
		fire_cd = 0.25
		return

	overcharge -= cost
	fire_cd = 0.45
	var aim_dir := (get_global_mouse_position() - player_pos).normalized()

	match h_gun["type"]:
		"swarm":
			screen_shake = 8.0
			_spawn_text(player_pos + Vector2(0, -36), "SWARM MISSILES! (-30⚡)", Color(0.3, 0.95, 1.0))
			for i in range(5):
				var ang := deg_to_rad(-24.0 + i * 12.0)
				var dir := aim_dir.rotated(ang)
				_spawn_bullet(player_pos + dir * 18.0, dir * 560.0, 34.0, "player", 7.0, false, false, true)
		"rail":
			screen_shake = 14.0
			hitstop_timer = 0.04
			_spawn_text(player_pos + Vector2(0, -36), "RAILGUN OVERDRIVE! (-50⚡)", Color(0.4, 1.0, 0.9))
			var beam_end := player_pos + aim_dir * 1100.0
			for e in enemies:
				if e["hp"] > 0.0:
					var closest := Geometry2D.get_closest_point_to_segment(e["pos"], player_pos, beam_end)
					if closest.distance_to(e["pos"]) <= e["radius"] + 18.0:
						_damage_enemy(e, 95.0, false, true)
		"black_hole":
			screen_shake = 16.0
			hitstop_timer = 0.05
			_spawn_text(player_pos + Vector2(0, -36), "SINGULARITY UNLEASHED! (-90⚡)", Color(0.85, 0.4, 1.0))
			black_holes.append({
				"pos": player_pos + aim_dir * 45.0,
				"vel": aim_dir * 145.0,
				"timer": 3.2,
				"tick_cd": 0.0
			})
	# Auto-snap back to primary if not enough charge for another shot
	if overcharge < cost:
		using_heavy = false


func _trigger_active_item() -> void:
	if active_item["timer"] > 0.0:
		_spawn_text(player_pos + Vector2(0, -24), "Active Item Cooling Down...", Color.GRAY)
		return
	active_item["timer"] = active_item["cooldown"]
	screen_shake = 10.0
	var cleared: int = 0
	for b in bullets:
		if b["active"] and b["team"] == "enemy" and b["pos"].distance_to(player_pos) <= 240.0:
			b["active"] = false
			cleared += 1
	for e in enemies:
		if e["hp"] > 0.0 and e["pos"].distance_to(player_pos) <= 240.0:
			e["windup"] = 0.0
			_damage_enemy(e, 20.0, false)
	_spawn_text(player_pos + Vector2(0, -34), "EMP PULSE! Cleared %d bullets" % cleared, Color(0.4, 0.9, 1.0))
	if cleared >= 3 and _cur_dynamo()["id"] == "bullet_shatter":
		_add_overcharge(_cur_dynamo()["bonus"], "AEGIS SHATTER DYNAMO +28⚡")


func _update_black_holes(delta: float) -> void:
	for i in range(black_holes.size() - 1, -1, -1):
		var bh := black_holes[i]
		bh["timer"] -= delta
		bh["pos"] += bh["vel"] * delta
		bh["vel"] = bh["vel"].move_toward(Vector2.ZERO, delta * 60.0)
		bh["tick_cd"] -= delta

		# Pull enemies & devour enemy bullets
		for b in bullets:
			if b["active"] and b["team"] == "enemy" and b["pos"].distance_to(bh["pos"]) <= 150.0:
				b["active"] = false

		var do_dmg: bool = bh["tick_cd"] <= 0.0
		if do_dmg:
			bh["tick_cd"] = 0.25
		for e in enemies:
			if e["hp"] > 0.0:
				var dist: float = e["pos"].distance_to(bh["pos"])
				if dist < 220.0 and dist > 12.0:
					e["pos"] += (bh["pos"] - e["pos"]).normalized() * 155.0 * delta
				if do_dmg and dist <= 130.0:
					_damage_enemy(e, 18.0, false)

		if bh["timer"] <= 0.0:
			black_holes.remove_at(i)


func _spawn_bullet(pos: Vector2, vel: Vector2, dmg: float, team: String, radius: float, is_final: bool, pierces: bool, homing: bool = false) -> void:
	for b in bullets:
		if not b["active"]:
			b["active"] = true
			b["pos"] = pos
			b["vel"] = vel
			b["dmg"] = dmg
			b["team"] = team
			b["radius"] = radius
			b["is_final"] = is_final
			b["pierces"] = pierces
			b["homing"] = homing
			b["grazed"] = false
			return
	bullets.append({
		"active": true,
		"pos": pos,
		"vel": vel,
		"dmg": dmg,
		"team": team,
		"radius": radius,
		"is_final": is_final,
		"pierces": pierces,
		"homing": homing,
		"grazed": false
	})


func _update_bullets(delta: float) -> void:
	var graze_r := GRAZE_RADIUS * (1.25 if _has_passive("fleet_step") else 1.0)
	for b in bullets:
		if not b["active"]:
			continue

		if b["homing"] and b["team"] == "player":
			var nearest_e: Dictionary = {}
			var best_d: float = 99999.0
			for e in enemies:
				if e["hp"] > 0.0:
					var d: float = e["pos"].distance_to(b["pos"])
					if d < best_d:
						best_d = d
						nearest_e = e
			if not nearest_e.is_empty():
				var desired: Vector2 = (nearest_e["pos"] - b["pos"]).normalized() * b["vel"].length()
				b["vel"] = b["vel"].lerp(desired, delta * 8.0)

		b["pos"] += b["vel"] * delta
		if not ARENA_RECT.has_point(b["pos"]):
			b["active"] = false
			continue

		# Check flipped table cover collision
		for t in cover_tables:
			if t["flipped"] and t["hp"] > 0.0 and t["rect"].has_point(b["pos"]):
				if b["team"] == "enemy":
					t["hp"] -= 10.0
					b["active"] = false
					break

		if not b["active"]:
			continue

		# Check explosive barrels
		if b["team"] == "player":
			for br in barrels:
				if br["alive"] and br["pos"].distance_to(b["pos"]) <= 22.0:
					_detonate_barrel(br)
					if not b["pierces"]:
						b["active"] = false
					break

		if not b["active"]:
			continue

		if b["team"] == "player":
			for e in enemies:
				if e["hp"] > 0.0 and e["pos"].distance_to(b["pos"]) <= e["radius"] + b["radius"]:
					_damage_enemy(e, b["dmg"], b["is_final"], true)
					if not b["pierces"]:
						b["active"] = false
						break
		else:
			# Enemy bullet -> Check Dodge Roll I-frame Graze first!
			var dist_to_player: float = b["pos"].distance_to(player_pos)
			var in_iframes: bool = is_dodging and dodge_timer <= DODGE_IFRAME_END
			if in_iframes and not b["grazed"] and dist_to_player <= graze_r and dodge_grazed_count < 2:
				b["grazed"] = true
				dodge_grazed_count += 1
				_add_overcharge(CHARGE_DODGE_GRAZE, "GRAZE! +20⚡")

			if dist_to_player <= PLAYER_RADIUS + b["radius"] - 2.0:
				if in_iframes:
					# Safely rolled right through the bullet!
					continue
				b["active"] = false
				_damage_player(1)


func _detonate_barrel(br: Dictionary) -> void:
	br["alive"] = false
	screen_shake = 12.0
	hitstop_timer = 0.03
	_spawn_text(br["pos"], "BOOM!", Color(1.0, 0.55, 0.1))
	var hit_any: bool = false
	for e in enemies:
		if e["hp"] > 0.0 and e["pos"].distance_to(br["pos"]) <= 135.0:
			hit_any = true
			_damage_enemy(e, 65.0, false)
	if hit_any and _cur_dynamo()["id"] == "barrel_kick":
		_add_overcharge(_cur_dynamo()["bonus"], "DEMOLITION DYNAMO +40⚡")


func _damage_enemy(e: Dictionary, amount: float, is_final: bool, from_direct_shot: bool = false) -> void:
	if e["hp"] <= 0.0:
		return
	e["hp"] -= amount
	e["flash"] = 0.12

	if from_direct_shot:
		if is_final:
			_add_overcharge(CHARGE_FINAL_ROUND_HIT, "FINAL HIT +8⚡")
		else:
			_add_overcharge(CHARGE_NORMAL_HIT, "")

	# Tier-1 Weak-Point Red-Flash Interrupt!
	if e["windup"] > 0.0 and (is_final or amount >= 25.0):
		e["windup"] = 0.0
		e["fire_cd"] = 1.6
		hitstop_timer = 0.04
		_add_overcharge(CHARGE_WEAKPOINT_INTERRUPT, "WEAK-POINT INTERRUPT! +35⚡")

	if e["hp"] <= 0.0:
		var shell_drop: int = 12 if not active_overdrive_bet else 24
		scrap_shells += shell_drop
		_spawn_text(e["pos"], "+%d Shells" % shell_drop, Color(1.0, 0.88, 0.3))
		if elapsed_time - last_kill_time <= 3.0 and _cur_dynamo()["id"] == "kill_chain":
			_add_overcharge(_cur_dynamo()["bonus"], "RAMPAGE DYNAMO +12⚡")
		last_kill_time = elapsed_time


func _damage_player(dmg: int) -> void:
	if invuln_timer > 0.0:
		return
	invuln_timer = 1.0
	screen_shake = 14.0
	if armor > 0:
		armor -= 1
		_spawn_text(player_pos + Vector2(0, -30), "ARMOR BROKEN!", Color(0.4, 0.8, 1.0))
	else:
		hp = maxi(1, hp - dmg) # Keep at minimum 1 HP in prototype so player never gets stuck
		_spawn_text(player_pos + Vector2(0, -30), "-1 HP!", Color(1.0, 0.25, 0.25))


func _add_overcharge(amount: float, label: String) -> void:
	overcharge = clampf(overcharge + amount, 0.0, max_overcharge)
	if label != "":
		_spawn_text(player_pos + Vector2(randf_range(-24, 24), -42), label, Color(0.3, 1.0, 0.85))


func _update_enemies(delta: float) -> void:
	var speed_mult: float = 1.28 if active_overdrive_bet else 1.0
	for e in enemies:
		if e["hp"] <= 0.0:
			continue
		if e["flash"] > 0.0:
			e["flash"] -= delta

		var to_player: Vector2 = player_pos - e["pos"]
		var dist: float = to_player.length()
		if dist > 160.0:
			e["pos"] += to_player.normalized() * e["speed"] * delta
		elif dist < 100.0:
			e["pos"] -= to_player.normalized() * e["speed"] * 0.6 * delta

		if e["windup"] > 0.0:
			e["windup"] -= delta
			if e["windup"] <= 0.0:
				_enemy_fire(e, speed_mult)
		else:
			e["fire_cd"] -= delta
			if e["fire_cd"] <= 0.0:
				e["windup"] = 0.55 # Red-flash interruptible wind-up window!
				e["fire_cd"] = e["cadence"]


func _enemy_fire(e: Dictionary, speed_mult: float) -> void:
	var aim: Vector2 = (player_pos - e["pos"]).normalized()
	match e["archetype"]:
		"burst":
			for ang_deg in [-18.0, 0.0, 18.0]:
				var d := aim.rotated(deg_to_rad(ang_deg))
				_spawn_bullet(e["pos"], d * 250.0 * speed_mult, 1.0, "enemy", 6.5, false, false)
		"ring":
			for i in range(8):
				var d := Vector2.RIGHT.rotated(TAU * float(i) / 8.0)
				_spawn_bullet(e["pos"], d * 210.0 * speed_mult, 1.0, "enemy", 6.5, false, false)
		"sniper":
			_spawn_bullet(e["pos"], aim * 370.0 * speed_mult, 1.0, "enemy", 7.5, false, false)


func _check_room_state() -> void:
	if room_cleared:
		return
	for e in enemies:
		if e["hp"] > 0.0:
			return
	room_cleared = true
	_spawn_three_category_doors()


func _spawn_three_category_doors() -> void:
	# Exactly matches the 3 Door Categories defined by the user:
	# 1. Armory Door (Primary / Heavy / Dynamo Core)
	# 2. Item Door (Active [Cap 1] / Passive [Cap 3])
	# 3. Random Event Door (Currency / HP / Overcharge Energy / Monster Bounty)
	doors = [
		{
			"cat": "armory",
			"title": "[1] ARMORY DOOR (枪械门)",
			"subtitle": "Drops: Primary / Heavy / Dynamo Core",
			"rect": Rect2(200.0, 92.0, 240.0, 54.0),
			"bet": false,
			"color": Color(1.0, 0.62, 0.2)
		},
		{
			"cat": "item",
			"title": "[2] TACTICAL ITEM DOOR (道具门)",
			"subtitle": "Drops: Active (Cap 1) / Passive (Cap 3)",
			"rect": Rect2(520.0, 92.0, 240.0, 54.0),
			"bet": false,
			"color": Color(0.3, 0.85, 1.0)
		},
		{
			"cat": "event",
			"title": "[3] RANDOM EVENT DOOR (事件门)",
			"subtitle": "Shop / HP-Energy Reactor / Bounty",
			"rect": Rect2(840.0, 92.0, 240.0, 54.0),
			"bet": false,
			"color": Color(0.85, 0.45, 1.0)
		}
	]


func _on_bet_pressed() -> void:
	if not room_cleared:
		return
	for d in doors:
		if d["rect"].grow(42.0).has_point(player_pos) and d["cat"] != "event":
			if not d["bet"]:
				if overcharge >= 25.0:
					overcharge -= 25.0
					d["bet"] = true
					_spawn_text(d["rect"].get_center(), "OVERDRIVE BET LOCKED! (-25⚡ -> 2x Drops)", Color(1.0, 0.35, 0.2))
				else:
					_spawn_text(player_pos + Vector2(0, -30), "Need 25⚡ to place Overdrive Bet!", Color(1.0, 0.4, 0.4))


func _on_interact_pressed() -> void:
	# Flip nearby cover table
	for t in cover_tables:
		if not t["flipped"] and t["hp"] > 0.0 and t["rect"].grow(38.0).has_point(player_pos):
			t["flipped"] = true
			screen_shake = 5.0
			_spawn_text(t["rect"].get_center(), "TABLE FLIPPED! (Blocks Bullets)", Color(0.9, 0.8, 0.5))
			# Clear immediate bullets around the table flip
			for b in bullets:
				if b["active"] and b["team"] == "enemy" and t["rect"].grow(26.0).has_point(b["pos"]):
					b["active"] = false
			return

	if not room_cleared:
		return

	# Check entering one of the 3 doors
	for d in doors:
		if d["rect"].grow(42.0).has_point(player_pos):
			_enter_door(d)
			return


func _enter_door(d: Dictionary) -> void:
	var cat: String = d["cat"]
	var bet: bool = d["bet"]
	room_number += 1

	# Grant previous room's category reward upon stepping through!
	match cat:
		"armory":
			heavy_idx = (heavy_idx + 1) % heavy_weapons.size()
			dynamo_idx = (dynamo_idx + 1) % dynamo_cores.size()
			current_event_popup = "ARMORY REWARD: Switched Heavy -> %s & Dynamo -> %s" % [_cur_heavy()["name"], _cur_dynamo()["name"]]
		"item":
			_grant_item_door_reward(bet)
		"event":
			_trigger_random_event_room()

	_setup_room(room_number, cat, bet)


func _grant_item_door_reward(bet: bool) -> void:
	var pool: Array[Dictionary] = [
		{"id": "wide_sweet", "name": "Chrono Slide-Stop", "desc": "Wider Perfect Reload sweet-spot window"},
		{"id": "final_amp", "name": "Omega Firing Pin", "desc": "Final Round deals +60% bonus damage"},
		{"id": "over_cap", "name": "Capacitor Coil", "desc": "Max Overcharge increased to 130"},
		{"id": "shell_magnet", "name": "Scrap Harvester", "desc": "Perfect Reloads grant +5 Scrap Shells"}
	]
	var candidate: Dictionary = pool[randi() % pool.size()]
	if _has_passive(candidate["id"]):
		scrap_shells += 25
		current_event_popup = "ITEM DOOR: Duplicate Passive Salvaged -> +25 Scrap Shells!"
		return

	if passive_items.size() < PASSIVE_CAP:
		passive_items.append(candidate)
		if candidate["id"] == "over_cap":
			max_overcharge = 130.0
		current_event_popup = "ITEM DOOR: Equipped Passive [%d/3]: %s" % [passive_items.size(), candidate["name"]]
	else:
		pending_passive_offer = candidate
		current_event_popup = "PASSIVE SLOTS FULL [3/3]! Press [7], [8], or [9] to swap & salvage (+20 Shells) for: " + candidate["name"]


func _resolve_passive_swap(slot_index: int) -> void:
	if pending_passive_offer.is_empty() or slot_index < 0 or slot_index >= passive_items.size():
		return
	var old_item := passive_items[slot_index]
	passive_items[slot_index] = pending_passive_offer
	scrap_shells += 20
	current_event_popup = "Swapped [%s] -> [%s] (+20 Shells Salvage!)" % [old_item["name"], pending_passive_offer["name"]]
	pending_passive_offer = {}


func _trigger_random_event_room() -> void:
	var roll: int = randi() % 3
	if roll == 0:
		# Pit-Stop Merchant & Heal
		if scrap_shells >= 25:
			scrap_shells -= 25
			hp = mini(max_hp, hp + 2)
			armor += 1
			current_event_popup = "EVENT [Pit-Stop Gunsmith]: Spent 25 Shells -> Restored +2 HP & +1 Armor!"
		else:
			hp = mini(max_hp, hp + 1)
			current_event_popup = "EVENT [Rest Workbench]: Emergency Patch -> Restored +1 HP!"
	elif roll == 1:
		# Blood-Overcharge Reactor (HP + Energy + Currency combo)
		overcharge = max_overcharge
		scrap_shells += 35
		current_event_popup = "EVENT [Overcharge Reactor]: Siphoned Anomaly -> Overcharge Filled to 100% + 35 Shells!"
	else:
		# High-Value Monster Ambush Event
		scrap_shells += 50
		current_event_popup = "EVENT [Vault Ambush]: Elite Bounty Activated! Clear room for +50 Bonus Shells!"


func _setup_room(r_num: int, cat: String, bet: bool) -> void:
	room_cleared = false
	active_overdrive_bet = bet
	bullets.clear()
	enemies.clear()
	black_holes.clear()
	doors.clear()
	player_pos = Vector2(640.0, 560.0)

	cover_tables = [
		{"rect": Rect2(350.0, 340.0, 95.0, 36.0), "flipped": false, "hp": 60.0},
		{"rect": Rect2(820.0, 340.0, 95.0, 36.0), "flipped": false, "hp": 60.0}
	]
	barrels = [
		{"pos": Vector2(490.0, 250.0), "alive": true},
		{"pos": Vector2(790.0, 250.0), "alive": true}
	]

	var count: int = 3 + mini(r_num, 3) + (1 if bet else 0)
	var archetypes := ["burst", "ring", "sniper"]
	for i in range(count):
		var arch: String = archetypes[i % archetypes.size()]
		enemies.append({
			"pos": Vector2(240.0 + i * (780.0 / float(maxi(1, count - 1))), randf_range(165.0, 255.0)),
			"hp": 85.0 + r_num * 12.0,
			"max_hp": 85.0 + r_num * 12.0,
			"speed": 75.0,
			"radius": 18.0,
			"archetype": arch,
			"cadence": 1.85,
			"fire_cd": 0.8 + i * 0.35,
			"windup": 0.0,
			"flash": 0.0
		})


func _spawn_text(pos: Vector2, txt: String, col: Color) -> void:
	floating_texts.append({"pos": pos, "text": txt, "color": col, "timer": 1.1})


func _update_floating_texts(delta: float) -> void:
	for i in range(floating_texts.size() - 1, -1, -1):
		floating_texts[i]["timer"] -= delta
		floating_texts[i]["pos"].y -= 28.0 * delta
		if floating_texts[i]["timer"] <= 0.0:
			floating_texts.remove_at(i)


func _draw() -> void:
	var shake_ofs := Vector2(randf_range(-screen_shake, screen_shake), randf_range(-screen_shake, screen_shake))
	draw_set_transform(shake_ofs, 0.0, Vector2.ONE)

	# 1. Low-saturation dark industrial floor (Pillar: Luminance Hierarchy < 35% value)
	draw_rect(Rect2(0, 0, 1280, 720), Color(0.08, 0.09, 0.12))
	draw_rect(ARENA_RECT, Color(0.14, 0.16, 0.20))
	draw_rect(ARENA_RECT, Color(0.32, 0.38, 0.46), false, 3.0)

	# Grid lines
	for gx in range(int(ARENA_RECT.position.x), int(ARENA_RECT.end.x), 80):
		draw_line(Vector2(gx, ARENA_RECT.position.y), Vector2(gx, ARENA_RECT.end.y), Color(0.18, 0.20, 0.25), 1.0)
	for gy in range(int(ARENA_RECT.position.y), int(ARENA_RECT.end.y), 80):
		draw_line(Vector2(ARENA_RECT.position.x, gy), Vector2(ARENA_RECT.end.x, gy), Color(0.18, 0.20, 0.25), 1.0)

	var font := ThemeDB.fallback_font

	# 2. Draw 3 Category Previewed Doors when Room is Cleared
	for d in doors:
		var r: Rect2 = d["rect"]
		var col: Color = d["color"]
		draw_rect(r, col.darkened(0.65))
		draw_rect(r, col, false, 3.0 if not d["bet"] else 5.0)
		draw_string(font, r.position + Vector2(10, 22), d["title"], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, col.lightened(0.3))
		draw_string(font, r.position + Vector2(10, 42), d["subtitle"], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
		if d["bet"]:
			draw_string(font, r.position + Vector2(10, -8), "★ OVERDRIVE BET ACTIVE (2x Drops!)", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1.0, 0.35, 0.2))
		elif d["cat"] != "event":
			draw_string(font, r.position + Vector2(10, -8), "[E] Enter   [F] Inject 25⚡ Bet", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.8, 0.9, 1.0))
		else:
			draw_string(font, r.position + Vector2(10, -8), "[E] Enter Event Room", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.9, 0.75, 1.0))

	# 3. Draw Cover Tables & Explosive Barrels
	for t in cover_tables:
		if t["hp"] <= 0.0:
			continue
		var col := Color(0.45, 0.35, 0.22) if not t["flipped"] else Color(0.75, 0.62, 0.35)
		draw_rect(t["rect"], col)
		draw_rect(t["rect"], Color.BLACK, false, 2.0)
		var lbl := "[E] Flip Table" if not t["flipped"] else "COVER (%d)" % int(t["hp"])
		draw_string(font, t["rect"].position + Vector2(6, 22), lbl, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)

	for br in barrels:
		if br["alive"]:
			draw_circle(br["pos"], 16.0, Color(0.85, 0.25, 0.15))
			draw_circle(br["pos"], 10.0, Color(1.0, 0.65, 0.1))
			draw_string(font, br["pos"] + Vector2(-18, -20), "TNT", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1.0, 0.8, 0.2))

	# 4. Draw Translucent Player Black Holes (Capped Alpha <= 45% under enemy bullets!)
	for bh in black_holes:
		draw_circle(bh["pos"], 125.0, Color(0.55, 0.2, 0.95, 0.25))
		draw_circle(bh["pos"], 32.0, Color(0.1, 0.02, 0.2, 0.45))
		draw_arc(bh["pos"], 125.0, 0.0, TAU, 48, Color(0.75, 0.4, 1.0, 0.45), 2.5)

	# 5. Draw Enemies & Interruptible Red-Flash Windups
	for e in enemies:
		if e["hp"] <= 0.0:
			continue
		var ecol := Color(0.95, 0.32, 0.32) if e["flash"] <= 0.0 else Color.WHITE
		if e["windup"] > 0.0:
			# High-visibility Weak-Point Interrupt window!
			draw_circle(e["pos"], e["radius"] + 12.0, Color(1.0, 0.15, 0.15, 0.35))
			draw_string(font, e["pos"] + Vector2(-42, -32), "⚡INTERRUPT! (+35⚡)", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1.0, 0.9, 0.2))
		draw_circle(e["pos"], e["radius"], ecol)
		# Enemy HP bar
		var hp_pct: float = clampf(e["hp"] / e["max_hp"], 0.0, 1.0)
		draw_rect(Rect2(e["pos"].x - 20, e["pos"].y - 26, 40, 5), Color(0.2, 0.2, 0.2))
		draw_rect(Rect2(e["pos"].x - 20, e["pos"].y - 26, 40 * hp_pct, 5), Color(1.0, 0.3, 0.3))

	# 6. Draw Player & Dodge Graze Ring
	var in_iframes: bool = is_dodging and dodge_timer <= DODGE_IFRAME_END
	var graze_r := GRAZE_RADIUS * (1.25 if _has_passive("fleet_step") else 1.0)
	if in_iframes:
		draw_arc(player_pos, graze_r, 0.0, TAU, 36, Color(0.2, 0.95, 1.0, 0.75), 2.5)
	else:
		draw_arc(player_pos, graze_r, 0.0, TAU, 36, Color(0.2, 0.7, 0.9, 0.18), 1.0)

	var p_col := Color(0.2, 1.0, 0.95) if in_iframes else (Color(1.0, 0.85, 0.2) if using_heavy else Color(0.3, 0.85, 0.45))
	draw_circle(player_pos, PLAYER_RADIUS, p_col)
	var aim_dir := (get_global_mouse_position() - player_pos).normalized()
	draw_line(player_pos, player_pos + aim_dir * 24.0, Color.WHITE, 3.5)

	# 7. Overhead Active Reload Slider Bar (Micro-UI directly above player)
	if is_reloading:
		var bar_pos := player_pos + Vector2(-36, -34)
		var bar_w: float = 72.0
		var p_gun := _cur_primary()
		var s_start: float = p_gun["sweet_start"]
		var s_end: float = p_gun["sweet_end"] + (0.08 if _has_passive("wide_sweet") else 0.0)
		draw_rect(Rect2(bar_pos.x, bar_pos.y, bar_w, 8), Color(0.15, 0.15, 0.18))
		draw_rect(Rect2(bar_pos.x + bar_w * s_start, bar_pos.y, bar_w * (s_end - s_start), 8), Color(1.0, 0.88, 0.15))
		var cursor_x := bar_pos.x + bar_w * clampf(reload_progress, 0.0, 1.0)
		draw_line(Vector2(cursor_x, bar_pos.y - 3), Vector2(cursor_x, bar_pos.y + 11), Color.WHITE, 3.0)
		draw_string(font, bar_pos + Vector2(0, -5), "[R] ACTIVE RELOAD", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1.0, 0.9, 0.3))

	# 8. Draw Pooled Projectiles (Enemy bullets on top layer with white core + bright red rim)
	for b in bullets:
		if not b["active"]:
			continue
		if b["team"] == "player":
			var bcol := Color(1.0, 0.82, 0.2) if b["is_final"] else Color(0.35, 0.95, 1.0)
			draw_circle(b["pos"], b["radius"], bcol)
		else:
			draw_circle(b["pos"], b["radius"] + 2.0, Color(1.0, 0.12, 0.22))
			draw_circle(b["pos"], b["radius"] * 0.55, Color.WHITE)

	# 9. Floating Combat Callouts
	for ft in floating_texts:
		draw_string(font, ft["pos"], ft["text"], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, ft["color"])

	# 10. Top & Bottom HUD (7-Slot Loadout + Overcharge Gauge + Controls)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_draw_hud(font)


func _draw_hud(font: Font) -> void:
	# Top Status Bar
	draw_rect(Rect2(0, 0, 1280, 82), Color(0.05, 0.06, 0.08, 0.95))
	draw_string(font, Vector2(20, 26), "ROOM #%d   HP: %d/%d   ARMOR: %d   SCRAP SHELLS: %d" % [room_number, hp, max_hp, armor, scrap_shells], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)

	# Overcharge Gauge
	var oc_pct := clampf(overcharge / max_overcharge, 0.0, 1.0)
	draw_rect(Rect2(480, 10, 320, 20), Color(0.18, 0.2, 0.25))
	draw_rect(Rect2(480, 10, 320 * oc_pct, 20), Color(0.25, 0.95, 0.85))
	draw_string(font, Vector2(490, 25), "OVERCHARGE: %d / %d ⚡ (Heavy Cost: %d⚡)" % [int(overcharge), int(max_overcharge), int(_cur_heavy()["cost"])], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.BLACK if oc_pct > 0.4 else Color.WHITE)

	var mode_str := "ACTIVE MODE: [HEAVY SPENDER]" if using_heavy else ("AMMO: %d / %d %s" % [ammo, _cur_primary()["mag_size"], "(NEXT IS FINAL ROUND!)" if ammo == 1 else ""])
	draw_string(font, Vector2(825, 26), mode_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(1.0, 0.85, 0.2) if (using_heavy or ammo == 1) else Color(0.6, 0.95, 1.0))

	# 7-Slot Loadout Readout (3 Armory + 1 Active + 3 Passives)
	draw_string(font, Vector2(20, 50), "ARMORY [Z/X/1-3] -> Primary: %s | Heavy [Q]: %s | Dynamo: %s" % [_cur_primary()["name"], _cur_heavy()["name"], _cur_dynamo()["name"]], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.85, 0.9, 1.0))

	var p_names: Array[String] = []
	for p in passive_items:
		p_names.append(p["name"])
	var cd_txt := "READY [C]" if active_item["timer"] <= 0.0 else ("%.1fs" % active_item["timer"])
	draw_string(font, Vector2(20, 72), "ITEMS -> Active (1/1): %s (%s) | Passives (%d/3): %s" % [active_item["name"], cd_txt, passive_items.size(), ", ".join(p_names)], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.6, 1.0, 0.75))

	# Bottom Banner / Controls & Event Log
	draw_rect(Rect2(0, 655, 1280, 65), Color(0.05, 0.06, 0.08, 0.95))
	if current_event_popup != "":
		draw_string(font, Vector2(20, 678), "LAST ROOM / EVENT: " + current_event_popup, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1.0, 0.88, 0.35))
	draw_string(font, Vector2(20, 704), "CONTROLS: [WASD] Move | [LMB] Fire | [RMB/Space] Dodge Roll (Graze=+20⚡) | [R] Active Reload (+14⚡) | [Q] Swap Heavy | [C] Active Item | [E] Flip Table / Enter Door | [F] Bet 25⚡ on Door | [Z/X/1-3] Test Guns & Dynamos", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.75, 0.8, 0.88))
