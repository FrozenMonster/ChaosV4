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
		"name": "维和者左轮",
		"mag_size": 6,
		"fire_interval": 0.20,
		"damage": 18.0,
		"bullet_speed": 820.0,
		"reload_time": 1.15,
		"sweet_start": 0.42,
		"sweet_end": 0.64,
		"final_round_desc": "尾弹：2.5倍伤害穿透高爆弹"
	},
	{
		"name": "矢量双持冲锋枪",
		"mag_size": 14,
		"fire_interval": 0.09,
		"damage": 9.0,
		"bullet_speed": 760.0,
		"reload_time": 1.05,
		"sweet_start": 0.48,
		"sweet_end": 0.68,
		"final_round_desc": "尾弹：三连发扇形电击弹"
	}
]
var primary_idx: int = 0

var heavy_weapons: Array[Dictionary] = [
	{
		"name": "蜂群微型导弹 [轻型]",
		"cost": 30.0,
		"type": "swarm",
		"desc": "消耗30⚡：发射5枚自动追踪导弹"
	},
	{
		"name": "超导电磁轨道炮 [中型]",
		"cost": 50.0,
		"type": "rail",
		"desc": "消耗50⚡：瞬发全屏穿透高能激光柱"
	},
	{
		"name": "奇点坍缩黑洞炮 [终极]",
		"cost": 90.0,
		"type": "black_hole",
		"desc": "消耗90⚡：牵引全场敌人并吞噬弹幕(3.2秒)"
	}
]
var heavy_idx: int = 0
var using_heavy: bool = false

var dynamo_cores: Array[Dictionary] = [
	{
		"id": "kill_chain",
		"name": "狂暴连杀核心 (简单: 连杀+12⚡)",
		"bonus": 12.0,
		"desc": "3秒内连续击杀敌人 -> +12⚡超载能量"
	},
	{
		"id": "bullet_shatter",
		"name": "神盾碎弹核心 (中等: 消弹+28⚡)",
		"bonus": 28.0,
		"desc": "完美换弹/EMP单次消除>=3颗子弹 -> +28⚡"
	},
	{
		"id": "barrel_kick",
		"name": "爆破轰击核心 (高难: 炸桶+40⚡)",
		"bonus": 40.0,
		"desc": "引爆炸药桶命中敌人 -> +40⚡巨额超载"
	}
]
var dynamo_idx: int = 0
var last_kill_time: float = -10.0

var active_item: Dictionary = {
	"name": "EMP 清弹脉冲",
	"cooldown": 8.0,
	"timer": 0.0,
	"desc": "[Q] 清除周围敌方弹幕并震慑敌人"
}

const PASSIVE_CAP: int = 3
var passive_items: Array[Dictionary] = [
	{"id": "shock_reload", "name": "特斯拉弹匣井", "desc": "完美换弹释放电弧并清除近身弹幕"},
	{"id": "fleet_step", "name": "动能推进靴", "desc": "+12% 移速并扩大擦弹吸收环"}
]
var pending_passive_offer: Dictionary = {}

# --- 美术贴图、音效与打击动效状态 (Sprites, SFX & Juice VFX) ---
var zh_font: Font
var tex_player: Texture2D
var tex_enemy_burst: Texture2D
var tex_enemy_ring: Texture2D
var tex_enemy_sniper: Texture2D
var tex_gun_revolver: Texture2D
var tex_gun_smg: Texture2D
var tex_gun_heavy: Texture2D
var sfx_players: Dictionary = {}

var shells: Array[Dictionary] = []
var afterimages: Array[Dictionary] = []
var shockwaves: Array[Dictionary] = []
var rail_beams: Array[Dictionary] = []
var debris_list: Array[Dictionary] = []
var muzzle_flash_timer: float = 0.0
var gun_recoil_offset: float = 0.0
var heavy_flash_timer: float = 0.0

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
	_load_assets_and_audio()
	ammo = _cur_primary()["mag_size"]
	_setup_room(1, "armory", false)


func _load_assets_and_audio() -> void:
	var font_file := FontFile.new()
	if font_file.load_dynamic_font("/System/Library/Fonts/STHeiti Medium.ttc") == OK:
		var sys_f := SystemFont.new()
		sys_f.font_names = PackedStringArray(["Apple Color Emoji", "Apple Symbols"])
		font_file.fallbacks = [sys_f]
		zh_font = font_file
	elif font_file.load_dynamic_font("/System/Library/Fonts/Hiragino Sans GB.ttc") == OK:
		zh_font = font_file
	else:
		var sys_font := SystemFont.new()
		sys_font.font_names = PackedStringArray(["STHeiti", "Hiragino Sans GB", "Heiti SC"])
		zh_font = sys_font

	tex_player = _load_png_tex("res://prototypes/chamber_overdrive_proto/assets/sprites/player_sheet.png")
	tex_enemy_burst = _load_png_tex("res://prototypes/chamber_overdrive_proto/assets/sprites/enemy_burst.png")
	tex_enemy_ring = _load_png_tex("res://prototypes/chamber_overdrive_proto/assets/sprites/enemy_ring.png")
	tex_enemy_sniper = _load_png_tex("res://prototypes/chamber_overdrive_proto/assets/sprites/enemy_sniper.png")
	tex_gun_revolver = _load_png_tex("res://prototypes/chamber_overdrive_proto/assets/sprites/gun_revolver.png")
	tex_gun_smg = _load_png_tex("res://prototypes/chamber_overdrive_proto/assets/sprites/gun_smg.png")
	tex_gun_heavy = _load_png_tex("res://prototypes/chamber_overdrive_proto/assets/sprites/gun_heavy.png")

	for sfx_name in ["shoot", "final_round", "perfect_reload", "jam", "graze", "heavy_fire", "explosion", "hit"]:
		var p := AudioStreamPlayer.new()
		p.stream = _load_wav_stream("res://prototypes/chamber_overdrive_proto/assets/sfx/%s.wav" % sfx_name)
		p.max_polyphony = 6
		add_child(p)
		sfx_players[sfx_name] = p


func _load_png_tex(res_path: String) -> Texture2D:
	var img := Image.new()
	var abs_p := ProjectSettings.globalize_path(res_path)
	if img.load(abs_p) == OK:
		return ImageTexture.create_from_image(img)
	return null


func _load_wav_stream(res_path: String) -> AudioStreamWAV:
	var abs_p := ProjectSettings.globalize_path(res_path)
	var f := FileAccess.open(abs_p, FileAccess.READ)
	if f == null:
		return null
	var buf := f.get_buffer(f.get_length())
	var wav := AudioStreamWAV.new()
	if buf.size() > 44:
		wav.data = buf.slice(44)
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 44100
	wav.stereo = false
	return wav


func _play_sfx(sfx_name: String, pitch_min: float = 0.95, pitch_max: float = 1.05) -> void:
	if sfx_players.has(sfx_name):
		var p: AudioStreamPlayer = sfx_players[sfx_name]
		if p.stream != null:
			p.pitch_scale = randf_range(pitch_min, pitch_max)
			p.play()


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
	if muzzle_flash_timer > 0.0:
		muzzle_flash_timer = maxf(0.0, muzzle_flash_timer - delta)
	if heavy_flash_timer > 0.0:
		heavy_flash_timer = maxf(0.0, heavy_flash_timer - delta)
	if gun_recoil_offset > 0.0:
		gun_recoil_offset = maxf(0.0, gun_recoil_offset - delta * 45.0)

	_handle_hotkeys()
	_update_player(delta)
	_update_weapons(delta)
	_update_enemies(delta)
	_update_black_holes(delta)
	_update_bullets(delta)
	_update_vfx(delta)
	_update_floating_texts(delta)
	_check_room_state()
	queue_redraw()


func _update_vfx(delta: float) -> void:
	for i in range(afterimages.size() - 1, -1, -1):
		afterimages[i]["timer"] -= delta
		if afterimages[i]["timer"] <= 0.0:
			afterimages.remove_at(i)
	for i in range(shockwaves.size() - 1, -1, -1):
		shockwaves[i]["timer"] -= delta
		shockwaves[i]["radius"] = lerpf(shockwaves[i]["radius"], shockwaves[i]["max_r"], delta * 12.0)
		if shockwaves[i]["timer"] <= 0.0:
			shockwaves.remove_at(i)
	for i in range(rail_beams.size() - 1, -1, -1):
		rail_beams[i]["timer"] -= delta
		if rail_beams[i]["timer"] <= 0.0:
			rail_beams.remove_at(i)
	for s in shells:
		if s["vel"].length_squared() > 1.0:
			s["pos"] += s["vel"] * delta
			s["vel"] = s["vel"].move_toward(Vector2.ZERO, delta * 360.0)
			s["rot"] += delta * 14.0
	for d in debris_list:
		if d["vel"].length_squared() > 1.0:
			d["pos"] += d["vel"] * delta
			d["vel"] = d["vel"].move_toward(Vector2.ZERO, delta * 420.0)


func _handle_hotkeys() -> void:
	if Input.is_key_pressed(KEY_1):
		dynamo_idx = 0
	elif Input.is_key_pressed(KEY_2):
		dynamo_idx = 1
	elif Input.is_key_pressed(KEY_3):
		dynamo_idx = 2


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_SPACE:
				_try_start_dodge()
			KEY_Q:
				_trigger_active_item()
			KEY_Z:
				primary_idx = (primary_idx + 1) % primary_weapons.size()
				ammo = _cur_primary()["mag_size"]
				is_reloading = false
				_spawn_text(player_pos + Vector2(0, -28), "切换主武器: " + _cur_primary()["name"], Color.WHITE)
			KEY_X:
				heavy_idx = (heavy_idx + 1) % heavy_weapons.size()
				_spawn_text(player_pos + Vector2(0, -28), "切换重火器: " + _cur_heavy()["name"], Color(1.0, 0.85, 0.2))
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
			_try_fire_heavy()


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
		if int(dodge_timer * 60.0) % 2 == 0:
			afterimages.append({"pos": player_pos, "timer": 0.20})
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
			_spawn_text(player_pos + Vector2(0, -24), "换弹完成", Color(0.8, 0.85, 0.9))

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_try_fire_primary()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		_try_fire_heavy()


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
		_play_sfx("perfect_reload", 0.98, 1.04)
		_add_overcharge(CHARGE_PERFECT_RELOAD, "★ 完美换弹! +14⚡")
		screen_shake = 7.0
		_trigger_perfect_reload_effects()
	else:
		# Missed sweet spot -> slight jam penalty
		reload_jammed = true
		_play_sfx("jam", 0.95, 1.02)
		_spawn_text(player_pos + Vector2(0, -32), "卡壳延迟! (错过黄区)", Color(1.0, 0.35, 0.3))


func _trigger_perfect_reload_effects() -> void:
	var cleared: int = 0
	var shock_radius: float = 135.0 if _has_passive("shock_reload") else 85.0
	shockwaves.append({"pos": player_pos, "radius": 18.0, "max_r": shock_radius, "timer": 0.28, "col": Color(1.0, 0.9, 0.25, 0.42)})
	if _has_passive("shell_magnet"):
		scrap_shells += 5
	for b in bullets:
		if b["active"] and b["team"] == "enemy" and b["pos"].distance_to(player_pos) <= shock_radius:
			b["active"] = false
			cleared += 1
	if _has_passive("shock_reload"):
		for e in enemies:
			if e["hp"] > 0.0 and e["pos"].distance_to(player_pos) <= shock_radius + 30.0:
				_damage_enemy(e, 26.0, false)
	if cleared >= 3 and _cur_dynamo()["id"] == "bullet_shatter":
		_add_overcharge(_cur_dynamo()["bonus"], "⚡神盾碎弹核心触发 +28⚡")


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
	muzzle_flash_timer = 0.06
	gun_recoil_offset = 8.0

	# Eject spinning brass shell casing
	var eject_dir := aim_dir.rotated(deg_to_rad(randf_range(95.0, 135.0)))
	shells.append({"pos": player_pos - aim_dir * 4.0, "vel": eject_dir * randf_range(95.0, 155.0), "rot": randf() * TAU})
	if shells.size() > 65:
		shells.pop_front()

	var dmg_mult: float = 1.25 if perfect_reload_buff_timer > 0.0 else 1.0
	if is_final_round and _has_passive("final_amp"):
		dmg_mult *= 1.6

	if is_final_round:
		_play_sfx("final_round", 0.96, 1.04)
		screen_shake = 8.0
		_spawn_text(player_pos + Vector2(0, -34), "★ 尾弹爆发 (FINAL ROUND)!", Color(1.0, 0.78, 0.2))
		if primary_idx == 0:
			_spawn_bullet(player_pos + aim_dir * 16.0, aim_dir * 960.0, p_gun["damage"] * 2.5 * dmg_mult, "player", 9.0, true, true)
		else:
			for angle_deg in [-14.0, 0.0, 14.0]:
				var dir := aim_dir.rotated(deg_to_rad(angle_deg))
				_spawn_bullet(player_pos + dir * 16.0, dir * 860.0, p_gun["damage"] * 1.9 * dmg_mult, "player", 7.0, true, true)
		is_reloading = true
		reload_progress = 0.0
		reload_attempted = false
		reload_jammed = false
	else:
		_play_sfx("shoot", 0.94, 1.08)
		screen_shake = maxf(screen_shake, 2.2)
		var spread := randf_range(-0.04, 0.04)
		var dir := aim_dir.rotated(spread)
		_spawn_bullet(player_pos + dir * 16.0, dir * p_gun["bullet_speed"], p_gun["damage"] * dmg_mult, "player", 5.0, false, false)


func _try_fire_heavy() -> void:
	if fire_cd > 0.0:
		return
	var h_gun := _cur_heavy()
	var cost: float = h_gun["cost"]
	if overcharge < cost:
		_play_sfx("jam", 1.1, 1.2)
		_spawn_text(player_pos + Vector2(0, -30), "超载能量不足! 需 %d⚡" % int(cost), Color(1.0, 0.35, 0.35))
		fire_cd = 0.25
		return

	overcharge -= cost
	fire_cd = 0.42
	heavy_flash_timer = 0.28
	gun_recoil_offset = 13.0
	_play_sfx("heavy_fire", 0.92, 1.05)
	var aim_dir := (get_global_mouse_position() - player_pos).normalized()

	match h_gun["type"]:
		"swarm":
			screen_shake = 9.0
			_spawn_text(player_pos + Vector2(0, -36), "★ 蜂群追踪导弹! (-30⚡)", Color(0.3, 0.95, 1.0))
			for i in range(5):
				var ang := deg_to_rad(-24.0 + i * 12.0)
				var dir := aim_dir.rotated(ang)
				_spawn_bullet(player_pos + dir * 18.0, dir * 560.0, 34.0, "player", 7.0, false, false, true)
		"rail":
			screen_shake = 15.0
			hitstop_timer = 0.045
			_spawn_text(player_pos + Vector2(0, -36), "★ 超导轨道炮轰击! (-50⚡)", Color(0.4, 1.0, 0.9))
			var beam_end := player_pos + aim_dir * 1100.0
			rail_beams.append({"start": player_pos + aim_dir * 16.0, "end": beam_end, "timer": 0.28})
			for e in enemies:
				if e["hp"] > 0.0:
					var closest := Geometry2D.get_closest_point_to_segment(e["pos"], player_pos, beam_end)
					if closest.distance_to(e["pos"]) <= e["radius"] + 20.0:
						_damage_enemy(e, 95.0, true, true)
		"black_hole":
			screen_shake = 17.0
			hitstop_timer = 0.055
			_spawn_text(player_pos + Vector2(0, -36), "★ 奇点黑洞降临! (-90⚡)", Color(0.85, 0.4, 1.0))
			black_holes.append({
				"pos": player_pos + aim_dir * 45.0,
				"vel": aim_dir * 145.0,
				"timer": 3.2,
				"tick_cd": 0.0
			})


func _trigger_active_item() -> void:
	if active_item["timer"] > 0.0:
		_spawn_text(player_pos + Vector2(0, -24), "主动道具冷却中...", Color.GRAY)
		return
	active_item["timer"] = active_item["cooldown"]
	_play_sfx("explosion", 1.15, 1.25)
	screen_shake = 11.0
	shockwaves.append({"pos": player_pos, "radius": 20.0, "max_r": 240.0, "timer": 0.35, "col": Color(0.3, 0.9, 1.0, 0.40)})
	var cleared: int = 0
	for b in bullets:
		if b["active"] and b["team"] == "enemy" and b["pos"].distance_to(player_pos) <= 240.0:
			b["active"] = false
			cleared += 1
	for e in enemies:
		if e["hp"] > 0.0 and e["pos"].distance_to(player_pos) <= 240.0:
			e["windup"] = 0.0
			_damage_enemy(e, 20.0, false)
	_spawn_text(player_pos + Vector2(0, -34), "EMP 清弹脉冲! 消除 %d 颗弹幕" % cleared, Color(0.4, 0.9, 1.0))
	if cleared >= 3 and _cur_dynamo()["id"] == "bullet_shatter":
		_add_overcharge(_cur_dynamo()["bonus"], "⚡神盾碎弹核心触发 +28⚡")


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
				_play_sfx("graze", 0.95, 1.15)
				_add_overcharge(CHARGE_DODGE_GRAZE, "★ 极限擦弹! +20⚡")

			if dist_to_player <= PLAYER_RADIUS + b["radius"] - 2.0:
				if in_iframes:
					continue
				b["active"] = false
				_damage_player(1)


func _detonate_barrel(br: Dictionary) -> void:
	br["alive"] = false
	_play_sfx("explosion", 0.9, 1.05)
	screen_shake = 14.0
	hitstop_timer = 0.035
	shockwaves.append({"pos": br["pos"], "radius": 24.0, "max_r": 140.0, "timer": 0.34, "col": Color(1.0, 0.5, 0.15, 0.44)})
	for k in range(10):
		var ang := randf() * TAU
		debris_list.append({"pos": br["pos"], "vel": Vector2.RIGHT.rotated(ang) * randf_range(90.0, 220.0), "col": Color(0.95, 0.45, 0.15)})
	_spawn_text(br["pos"], "★ 爆破桶轰炸!", Color(1.0, 0.55, 0.1))
	var hit_any: bool = false
	for e in enemies:
		if e["hp"] > 0.0 and e["pos"].distance_to(br["pos"]) <= 135.0:
			hit_any = true
			_damage_enemy(e, 65.0, true)
	if hit_any and _cur_dynamo()["id"] == "barrel_kick":
		_add_overcharge(_cur_dynamo()["bonus"], "⚡爆破轰击核心触发 +40⚡")


func _damage_enemy(e: Dictionary, amount: float, is_final: bool, from_direct_shot: bool = false) -> void:
	if e["hp"] <= 0.0:
		return
	e["hp"] -= amount
	e["flash"] = 0.12
	_play_sfx("hit", 0.9, 1.15)

	var dmg_col := Color(1.0, 0.85, 0.2) if (is_final or amount >= 30.0) else Color(0.95, 0.95, 1.0)
	var prefix := "暴击 -" if (is_final or amount >= 30.0) else "-"
	_spawn_text(e["pos"] + Vector2(randf_range(-16, 16), -22), "%s%d" % [prefix, int(amount)], dmg_col)

	if from_direct_shot:
		if is_final:
			_add_overcharge(CHARGE_FINAL_ROUND_HIT, "尾弹命中 +8⚡")
		else:
			_add_overcharge(CHARGE_NORMAL_HIT, "")

	# Tier-1 Weak-Point Red-Flash Interrupt!
	if e["windup"] > 0.0 and (is_final or amount >= 25.0):
		e["windup"] = 0.0
		e["fire_cd"] = 1.6
		hitstop_timer = 0.045
		_play_sfx("perfect_reload", 1.15, 1.25)
		shockwaves.append({"pos": e["pos"], "radius": 14.0, "max_r": 75.0, "timer": 0.25, "col": Color(1.0, 0.25, 0.25, 0.42)})
		_add_overcharge(CHARGE_WEAKPOINT_INTERRUPT, "★ 弱点蓄力打断! +35⚡")

	if e["hp"] <= 0.0:
		_play_sfx("explosion", 1.1, 1.28)
		for k in range(8):
			var ang := randf() * TAU
			debris_list.append({"pos": e["pos"], "vel": Vector2.RIGHT.rotated(ang) * randf_range(70.0, 180.0), "col": Color(0.55, 0.6, 0.68)})
		var shell_drop: int = 12 if not active_overdrive_bet else 24
		scrap_shells += shell_drop
		_spawn_text(e["pos"], "+%d 废料弹壳" % shell_drop, Color(1.0, 0.88, 0.3))
		if elapsed_time - last_kill_time <= 3.0 and _cur_dynamo()["id"] == "kill_chain":
			_add_overcharge(_cur_dynamo()["bonus"], "⚡狂暴连杀核心 +12⚡")
		last_kill_time = elapsed_time


func _damage_player(dmg: int) -> void:
	if invuln_timer > 0.0:
		return
	invuln_timer = 1.0
	_play_sfx("jam", 0.75, 0.85)
	screen_shake = 14.0
	if armor > 0:
		armor -= 1
		_spawn_text(player_pos + Vector2(0, -30), "护甲碎裂! (-1 护甲)", Color(0.4, 0.8, 1.0))
	else:
		hp = maxi(1, hp - dmg)
		_spawn_text(player_pos + Vector2(0, -30), "受击 -1 生命!", Color(1.0, 0.25, 0.25))


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
	doors = [
		{
			"cat": "armory",
			"title": "【1】军械库大门 (枪械门)",
			"subtitle": "掉落：主武器 / 重火器 / 充能核心",
			"rect": Rect2(200.0, 92.0, 240.0, 54.0),
			"bet": false,
			"color": Color(1.0, 0.62, 0.2)
		},
		{
			"cat": "item",
			"title": "【2】战术道具门 (道具门)",
			"subtitle": "掉落：主动道具(上限1) / 被动(上限3)",
			"rect": Rect2(520.0, 92.0, 240.0, 54.0),
			"bet": false,
			"color": Color(0.3, 0.85, 1.0)
		},
		{
			"cat": "event",
			"title": "【3】随机事件门 (事件门)",
			"subtitle": "黑市军火商 / 反应堆回血充能 / 悬赏怪",
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
					_play_sfx("perfect_reload", 0.9, 0.95)
					_spawn_text(d["rect"].get_center(), "★ 超载押注已锁定! (-25⚡ -> 下房双倍掉落)", Color(1.0, 0.35, 0.2))
				else:
					_play_sfx("jam", 1.0, 1.05)
					_spawn_text(player_pos + Vector2(0, -30), "超载押注需要 25⚡ 能量!", Color(1.0, 0.4, 0.4))


func _on_interact_pressed() -> void:
	for t in cover_tables:
		if not t["flipped"] and t["hp"] > 0.0 and t["rect"].grow(38.0).has_point(player_pos):
			t["flipped"] = true
			_play_sfx("hit", 0.75, 0.85)
			screen_shake = 6.0
			_spawn_text(t["rect"].get_center(), "★ 掀翻木桌掩体! (阻挡敌方弹幕)", Color(0.9, 0.8, 0.5))
			for b in bullets:
				if b["active"] and b["team"] == "enemy" and t["rect"].grow(26.0).has_point(b["pos"]):
					b["active"] = false
			return

	if not room_cleared:
		return

	for d in doors:
		if d["rect"].grow(42.0).has_point(player_pos):
			_enter_door(d)
			return


func _enter_door(d: Dictionary) -> void:
	var cat: String = d["cat"]
	var bet: bool = d["bet"]
	room_number += 1
	_play_sfx("perfect_reload", 1.0, 1.08)

	match cat:
		"armory":
			heavy_idx = (heavy_idx + 1) % heavy_weapons.size()
			dynamo_idx = (dynamo_idx + 1) % dynamo_cores.size()
			current_event_popup = "【军械门奖励】解锁切换重火器 -> %s | 充能核心 -> %s" % [_cur_heavy()["name"], _cur_dynamo()["name"]]
		"item":
			_grant_item_door_reward(bet)
		"event":
			_trigger_random_event_room()

	_setup_room(room_number, cat, bet)


func _grant_item_door_reward(_bet: bool) -> void:
	var pool: Array[Dictionary] = [
		{"id": "wide_sweet", "name": "时序滑块卡扣", "desc": "大幅拓宽主动换弹的黄色完美判定区"},
		{"id": "final_amp", "name": "欧米茄强化撞针", "desc": "尾弹(Final Round)额外造成 +60% 暴击伤害"},
		{"id": "over_cap", "name": "高压电容线圈", "desc": "最大超载能量上限提升至 130⚡"},
		{"id": "shell_magnet", "name": "磁力废料回收器", "desc": "每次触发完美换弹额外获得 +5 废料弹壳"}
	]
	var candidate: Dictionary = pool[randi() % pool.size()]
	if _has_passive(candidate["id"]):
		scrap_shells += 25
		current_event_popup = "【道具门】重复被动自动拆解 -> 获得 +25 废料弹壳!"
		return

	if passive_items.size() < PASSIVE_CAP:
		passive_items.append(candidate)
		if candidate["id"] == "over_cap":
			max_overcharge = 130.0
		current_event_popup = "【道具门】装备新被动 [%d/3]：%s (%s)" % [passive_items.size(), candidate["name"], candidate["desc"]]
	else:
		pending_passive_offer = candidate
		current_event_popup = "【被动槽已满 3/3】按数字键 [7]、[8] 或 [9] 替换旧被动并拆解回收(+20弹壳) -> 新被动：" + candidate["name"]


func _resolve_passive_swap(slot_index: int) -> void:
	if pending_passive_offer.is_empty() or slot_index < 0 or slot_index >= passive_items.size():
		return
	var old_item := passive_items[slot_index]
	passive_items[slot_index] = pending_passive_offer
	scrap_shells += 20
	_play_sfx("perfect_reload", 1.05, 1.1)
	current_event_popup = "已替换 [%s] -> [%s] (旧件拆解 +20 废料弹壳!)" % [old_item["name"], pending_passive_offer["name"]]
	pending_passive_offer = {}


func _trigger_random_event_room() -> void:
	var roll: int = randi() % 3
	if roll == 0:
		if scrap_shells >= 25:
			scrap_shells -= 25
			hp = mini(max_hp, hp + 2)
			armor += 1
			current_event_popup = "【事件门·整备铁匠铺】消耗 25 弹壳 -> 恢复 +2 生命 & 锻造 +1 护甲!"
		else:
			hp = mini(max_hp, hp + 1)
			current_event_popup = "【事件门·应急维修台】免费紧急包扎 -> 恢复 +1 生命!"
	elif roll == 1:
		overcharge = max_overcharge
		scrap_shells += 35
		current_event_popup = "【事件门·超载反应堆】汲取异常能量 -> 超载槽瞬间充满 100% + 获得 35 弹壳!"
	else:
		scrap_shells += 50
		current_event_popup = "【事件门·金库伏击悬赏】精英悬赏触发! 清理本房间直接入账 +50 赏金弹壳!"


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

	var font: Font = zh_font if zh_font != null else ThemeDB.fallback_font

	# 1.5 Draw Floor Shell Casings & Mechanical Debris
	for s in shells:
		draw_rect(Rect2(s["pos"].x - 3, s["pos"].y - 1.5, 6, 3), Color(0.92, 0.72, 0.22, 0.85))
	for d in debris_list:
		draw_rect(Rect2(d["pos"].x - 3, d["pos"].y - 3, 6, 6), d["col"])

	# 2. Draw 3 Category Previewed Doors when Room is Cleared
	for d in doors:
		var r: Rect2 = d["rect"]
		var col: Color = d["color"]
		draw_rect(r, col.darkened(0.65))
		draw_rect(r, col, false, 3.0 if not d["bet"] else 5.0)
		draw_string(font, r.position + Vector2(10, 22), d["title"], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, col.lightened(0.3))
		draw_string(font, r.position + Vector2(10, 42), d["subtitle"], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
		if d["bet"]:
			draw_string(font, r.position + Vector2(10, -8), "★ 已注入超载押注 (下房双倍奖励!)", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1.0, 0.35, 0.2))
		elif d["cat"] != "event":
			draw_string(font, r.position + Vector2(10, -8), "[E] 进门   [F] 注入 25⚡ 开启超载押注", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.8, 0.9, 1.0))
		else:
			draw_string(font, r.position + Vector2(10, -8), "[E] 进入随机事件房", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.9, 0.75, 1.0))

	# 3. Draw Cover Tables & Explosive Barrels
	for t in cover_tables:
		if t["hp"] <= 0.0:
			continue
		var col := Color(0.45, 0.35, 0.22) if not t["flipped"] else Color(0.75, 0.62, 0.35)
		draw_rect(t["rect"], col)
		draw_rect(t["rect"], Color.BLACK, false, 2.0)
		var lbl := "[E] 掀桌掩体" if not t["flipped"] else "掩体耐久 (%d)" % int(t["hp"])
		draw_string(font, t["rect"].position + Vector2(6, 22), lbl, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)

	for br in barrels:
		if br["alive"]:
			draw_circle(br["pos"], 16.0, Color(0.85, 0.25, 0.15))
			draw_circle(br["pos"], 10.0, Color(1.0, 0.65, 0.1))
			draw_string(font, br["pos"] + Vector2(-22, -20), "炸药桶", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1.0, 0.8, 0.2))

	# 4. Draw Translucent Player Black Holes, Shockwaves & Railgun Beams (Capped Alpha <= 45% under enemy bullets!)
	for sw in shockwaves:
		draw_arc(sw["pos"], sw["radius"], 0.0, TAU, 48, sw["col"], 4.0)
		draw_circle(sw["pos"], sw["radius"], Color(sw["col"].r, sw["col"].g, sw["col"].b, 0.12))
	for rb in rail_beams:
		var a_pct: float = clampf(rb["timer"] / 0.28, 0.0, 1.0)
		draw_line(rb["start"], rb["end"], Color(0.3, 1.0, 0.95, 0.42 * a_pct), 24.0 * a_pct)
		draw_line(rb["start"], rb["end"], Color(1.0, 1.0, 1.0, 0.85 * a_pct), 6.0 * a_pct)
	for bh in black_holes:
		draw_circle(bh["pos"], 125.0, Color(0.55, 0.2, 0.95, 0.22))
		draw_circle(bh["pos"], 32.0, Color(0.1, 0.02, 0.2, 0.45))
		draw_arc(bh["pos"], 125.0, elapsed_time * 3.0, elapsed_time * 3.0 + TAU * 0.8, 36, Color(0.8, 0.45, 1.0, 0.45), 3.0)

	# 5. Draw Enemies (Pixel Sprites + Hit-Flash + Interruptible Red-Flash Windups)
	for e in enemies:
		if e["hp"] <= 0.0:
			continue
		if e["windup"] > 0.0:
			draw_circle(e["pos"], e["radius"] + 14.0, Color(1.0, 0.15, 0.15, 0.35))
			draw_string(font, e["pos"] + Vector2(-52, -32), "⚡弱点蓄力! 重击打断(+35⚡)", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1.0, 0.9, 0.2))

		var etex: Texture2D = tex_enemy_burst
		if e["archetype"] == "ring":
			etex = tex_enemy_ring
		elif e["archetype"] == "sniper":
			etex = tex_enemy_sniper

		var mod_col := Color(3.0, 3.0, 3.0, 1.0) if e["flash"] > 0.0 else Color.WHITE
		if etex != null:
			var sz := etex.get_size()
			draw_texture_rect(etex, Rect2(e["pos"] - sz * 0.5, sz), false, mod_col)
		else:
			draw_circle(e["pos"], e["radius"], Color.WHITE if e["flash"] > 0.0 else Color(0.95, 0.32, 0.32))

		var hp_pct: float = clampf(e["hp"] / e["max_hp"], 0.0, 1.0)
		draw_rect(Rect2(e["pos"].x - 20, e["pos"].y - 26, 40, 5), Color(0.2, 0.2, 0.2))
		draw_rect(Rect2(e["pos"].x - 20, e["pos"].y - 26, 40 * hp_pct, 5), Color(1.0, 0.3, 0.3))

	# 6. Draw Player Afterimages, Dodge Graze Ring, Animated Pixel Sheet & Gun Sprite
	for ai in afterimages:
		var a_alpha: float = clampf(ai["timer"] / 0.20, 0.0, 1.0) * 0.45
		if tex_player != null:
			draw_texture_rect_region(tex_player, Rect2(ai["pos"] - Vector2(24, 18), Vector2(48, 36)), Rect2(0, 0, 48, 36), Color(0.2, 0.95, 1.0, a_alpha))
		else:
			draw_circle(ai["pos"], PLAYER_RADIUS, Color(0.2, 0.95, 1.0, a_alpha))

	var in_iframes: bool = is_dodging and dodge_timer <= DODGE_IFRAME_END
	var graze_r := GRAZE_RADIUS * (1.25 if _has_passive("fleet_step") else 1.0)
	if in_iframes:
		draw_arc(player_pos, graze_r, 0.0, TAU, 36, Color(0.2, 0.95, 1.0, 0.80), 2.5)
	else:
		draw_arc(player_pos, graze_r, 0.0, TAU, 36, Color(0.2, 0.7, 0.9, 0.18), 1.0)

	var aim_dir := (get_global_mouse_position() - player_pos).normalized()
	if tex_player != null:
		var moving: bool = player_vel.length_squared() > 20.0
		var frame_idx: int = int(elapsed_time * (12.0 if moving else 4.0)) % 4
		var src_rect := Rect2(frame_idx * 48.0, 0.0, 48.0, 36.0)
		var dst_size := Vector2(48.0, 36.0)
		if is_dodging:
			dst_size = Vector2(54.0, 30.0)
		var p_mod := Color(0.5, 1.0, 1.0, 1.0) if in_iframes else Color.WHITE
		draw_texture_rect_region(tex_player, Rect2(player_pos - dst_size * 0.5, dst_size), src_rect, p_mod)
	else:
		draw_circle(player_pos, PLAYER_RADIUS, Color(0.2, 1.0, 0.95) if in_iframes else Color(0.3, 0.85, 0.45))

	# Draw Handcrafted Rotated Gun Sprite + Recoil + Muzzle Flash
	var gun_tex: Texture2D = tex_gun_heavy if heavy_flash_timer > 0.0 else (tex_gun_revolver if primary_idx == 0 else tex_gun_smg)
	var gun_pos := player_pos + aim_dir * (16.0 - gun_recoil_offset)
	if gun_tex != null:
		draw_set_transform(shake_ofs + gun_pos, aim_dir.angle(), Vector2.ONE)
		var gsz := gun_tex.get_size()
		draw_texture_rect(gun_tex, Rect2(-gsz * 0.3, gsz), false)
		if muzzle_flash_timer > 0.0 or heavy_flash_timer > 0.20:
			draw_circle(Vector2(gsz.x * 0.7, 0), 9.0, Color(1.0, 0.92, 0.35, 0.9))
			draw_circle(Vector2(gsz.x * 0.7, 0), 5.0, Color.WHITE)
		draw_set_transform(shake_ofs, 0.0, Vector2.ONE)
	else:
		draw_line(player_pos, gun_pos + aim_dir * 12.0, Color.WHITE, 3.5)

	# 7. Overhead Active Reload Slider Bar (Micro-UI directly above player)
	if is_reloading:
		var bar_pos := player_pos + Vector2(-36, -36)
		var bar_w: float = 72.0
		var p_gun := _cur_primary()
		var s_start: float = p_gun["sweet_start"]
		var s_end: float = p_gun["sweet_end"] + (0.08 if _has_passive("wide_sweet") else 0.0)
		draw_rect(Rect2(bar_pos.x, bar_pos.y, bar_w, 8), Color(0.15, 0.15, 0.18))
		draw_rect(Rect2(bar_pos.x + bar_w * s_start, bar_pos.y, bar_w * (s_end - s_start), 8), Color(1.0, 0.88, 0.15))
		var cursor_x := bar_pos.x + bar_w * clampf(reload_progress, 0.0, 1.0)
		draw_line(Vector2(cursor_x, bar_pos.y - 3), Vector2(cursor_x, bar_pos.y + 11), Color.WHITE, 3.0)
		draw_string(font, bar_pos + Vector2(-4, -5), "[R] 抓黄区完美换弹", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1.0, 0.9, 0.3))

	# 8. Draw Pooled Projectiles (Enemy bullets on top layer with white core + bright red rim)
	for b in bullets:
		if not b["active"]:
			continue
		if b["team"] == "player":
			var bcol := Color(1.0, 0.82, 0.2) if b["is_final"] else (Color(0.4, 1.0, 0.85) if b["homing"] else Color(0.35, 0.95, 1.0))
			draw_circle(b["pos"], b["radius"], bcol)
			draw_circle(b["pos"], b["radius"] * 0.5, Color.WHITE)
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
	draw_rect(Rect2(0, 0, 1280, 84), Color(0.05, 0.06, 0.08, 0.95))
	draw_string(font, Vector2(20, 26), "房间 #%d   ❤️生命: %d/%d   🛡️护甲: %d   🪙废料弹壳: %d" % [room_number, hp, max_hp, armor, scrap_shells], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)

	var oc_pct := clampf(overcharge / max_overcharge, 0.0, 1.0)
	var h_cost: float = _cur_heavy()["cost"]
	var ready_heavy: bool = overcharge >= h_cost
	draw_rect(Rect2(470, 8, 340, 22), Color(0.18, 0.2, 0.25))
	draw_rect(Rect2(470, 8, 340 * oc_pct, 22), Color(1.0, 0.82, 0.2) if ready_heavy else Color(0.25, 0.95, 0.85))
	var oc_label := "⚡超载能量: %d / %d (右键重火器消耗: %d⚡%s)" % [int(overcharge), int(max_overcharge), int(h_cost), " [可发射!]" if ready_heavy else ""]
	draw_string(font, Vector2(478, 24), oc_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.BLACK if oc_pct > 0.35 else Color.WHITE)

	var mode_str := "弹匣: %d / %d %s" % [ammo, _cur_primary()["mag_size"], "★下一发是【尾弹】!" if ammo == 1 else ""]
	draw_string(font, Vector2(830, 26), mode_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(1.0, 0.85, 0.2) if ammo == 1 else Color(0.6, 0.95, 1.0))

	draw_string(font, Vector2(20, 50), "【军械 3槽】(按Z/X/1-3可随时测试切换) -> 左键主枪: %s | 右键重火器: %s | 核心: %s" % [_cur_primary()["name"], _cur_heavy()["name"], _cur_dynamo()["name"]], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.85, 0.9, 1.0))

	var p_names: Array[String] = []
	for p in passive_items:
		p_names.append(p["name"])
	var cd_txt := "就绪 [按Q释放]" if active_item["timer"] <= 0.0 else ("冷却 %.1f秒" % active_item["timer"])
	draw_string(font, Vector2(20, 73), "【战术道具 4槽】-> 主动(1/1): %s (%s) | 被动(%d/3): %s" % [active_item["name"], cd_txt, passive_items.size(), "、".join(p_names)], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.6, 1.0, 0.75))

	draw_rect(Rect2(0, 654, 1280, 66), Color(0.05, 0.06, 0.08, 0.95))
	if current_event_popup != "":
		draw_string(font, Vector2(20, 678), "📢 房间结算与掉落: " + current_event_popup, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1.0, 0.88, 0.35))
	draw_string(font, Vector2(20, 704), "操作键位：[WASD]移动 | [空格]翻滚(擦弹+20⚡) | [左键]主武器 | [右键]瞬发重火器 | [R]主动换弹(+14⚡) | [Q]主动道具 | [E]掀桌/进门 | [F]门前押注25⚡ | [Z/X/1-3]切换枪械与核心", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.82, 0.88, 0.96))
