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

# --- Tier 1 Base Action Overcharge Values (Calibrated for 72-100⚡ Room Budget & 1-2 Heavy Casts/Room) ---
const CHARGE_NORMAL_HIT: float = 0.5
const CHARGE_FINAL_ROUND_HIT: float = 4.0
const CHARGE_PERFECT_RELOAD: float = 8.0
const CHARGE_DODGE_GRAZE: float = 10.0
const CHARGE_WEAKPOINT_INTERRUPT: float = 22.0

# --- Player State ---
var player_pos: Vector2 = Vector2(640.0, 520.0)
var player_vel: Vector2 = Vector2.ZERO
var recoil_slide_vel: Vector2 = Vector2.ZERO
var last_move_dir: Vector2 = Vector2.UP
var hp: int = 6
var max_hp: int = 6
var aegis_shield: int = 1
var max_aegis_shield: int = 1
var aegis_pips: int = 0
var combat_perfect_reloads: int = 0
var bounty_chips: int = 60
var overcharge: float = 45.0
var max_overcharge: float = 100.0
var invuln_timer: float = 0.0
var heavy_cd_timer: float = 0.0
var gunslinger_crit_shots: int = 0
var shotgun_bonus_pellets: int = 0

# Dodge state
var is_dodging: bool = false
var dodge_timer: float = 0.0
var dodge_dir: Vector2 = Vector2.ZERO
var dodge_grazed_count: int = 0

# --- Loadout Schema (1 Primary + 1 Heavy + 1 Dynamo Core | 1 Active + Max 3 Passives) ---
var primary_weapons: Array[Dictionary] = [
	{
		"name": "维和者左轮 [精良·蓝]",
		"mag_size": 6,
		"fire_interval": 0.20,
		"damage": 18.0,
		"bullet_speed": 820.0,
		"reload_time": 1.15,
		"sweet_start": 0.42,
		"sweet_end": 0.62,
		"sig_buff": "【快枪手凝神】前2发必暴击(+40%)且2倍弹速"
	},
	{
		"name": "矢量双持冲锋枪 [违禁·紫]",
		"mag_size": 16,
		"fire_interval": 0.09,
		"damage": 9.0,
		"bullet_speed": 760.0,
		"reload_time": 0.95,
		"sweet_start": 0.22,
		"sweet_end": 0.40,
		"sig_buff": "【超频狂飙】射速+35%且零散射激光弹道"
	},
	{
		"name": "催收员重型霰弹 [超载·金]",
		"mag_size": 4,
		"fire_interval": 0.46,
		"damage": 11.0,
		"bullet_speed": 720.0,
		"reload_time": 1.35,
		"sweet_start": 0.65,
		"sweet_end": 0.81,
		"sig_buff": "【膛压震波】125px大清弹+下发霰弹+3弹片"
	}
]
var primary_idx: int = 0

var heavy_weapons: Array[Dictionary] = [
	{
		"name": "蜂群微型导弹 [45⚡轻型]",
		"cost": 45.0,
		"cd": 2.5,
		"recoil_px": 100.0,
		"type": "swarm",
		"desc": "消耗45⚡：发射5枚自动追踪导弹 (后坐滑步8px)"
	},
	{
		"name": "超导电磁轨道炮 [65⚡中型]",
		"cost": 65.0,
		"cd": 3.5,
		"recoil_px": 200.0,
		"type": "rail",
		"desc": "消耗65⚡：瞬发全屏穿透激光柱 (后坐滑步16px)"
	},
	{
		"name": "奇点坍缩黑洞炮 [90⚡终极]",
		"cost": 90.0,
		"cd": 5.0,
		"recoil_px": 275.0,
		"type": "black_hole",
		"desc": "消耗90⚡：牵引敌人并吞噬弹幕 (后坐滑步22px)"
	}
]
var heavy_idx: int = 0
var using_heavy: bool = false

var dynamo_cores: Array[Dictionary] = [
	{
		"id": "kill_chain",
		"name": "狂暴连杀核心 (连杀+6⚡)",
		"bonus": 6.0,
		"desc": "3秒内连续击杀敌人 -> +6⚡"
	},
	{
		"id": "bullet_shatter",
		"name": "神盾碎弹核心 (消弹+14⚡)",
		"bonus": 14.0,
		"desc": "完美换弹/EMP/升盾单次消除>=3颗子弹 -> +14⚡"
	},
	{
		"id": "barrel_kick",
		"name": "战术机关核心 (机关命中+22⚡)",
		"bonus": 22.0,
		"desc": "利用燃料罐/液氮罐/折射棱镜命中敌人 -> +22⚡"
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
var cryo_zones: Array[Dictionary] = []
var beacons: Array[Dictionary] = []
var black_holes: Array[Dictionary] = []
var floating_texts: Array[Dictionary] = []
var doors: Array[Dictionary] = []

# --- Room & Progression State ---
var room_number: int = 1
var room_cleared: bool = false
var room_objective: String = "EXTERMINATION" # EXTERMINATION, SABOTAGE_BEACONS, OVERDRIVE_SURVIVAL
var survival_timer: float = 0.0
var active_overdrive_bet: bool = false
var current_event_popup: String = ""
var screen_shake: float = 0.0
var camera_kick_ofs: Vector2 = Vector2.ZERO
var hitstop_timer: float = 0.0
var elapsed_time: float = 0.0
var player_squash: Vector2 = Vector2.ONE
var forge_dmg_mult: float = 1.0
var forge_graze_cap_bonus: int = 0


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

	if screen_shake > 0.0:
		screen_shake = maxf(0.0, screen_shake - delta * 28.0)
	if invuln_timer > 0.0:
		invuln_timer = maxf(0.0, invuln_timer - delta)
	if perfect_reload_buff_timer > 0.0:
		perfect_reload_buff_timer = maxf(0.0, perfect_reload_buff_timer - delta)
	if active_item["timer"] > 0.0:
		active_item["timer"] = maxf(0.0, active_item["timer"] - delta)
	if heavy_cd_timer > 0.0:
		heavy_cd_timer = maxf(0.0, heavy_cd_timer - delta)
	if muzzle_flash_timer > 0.0:
		muzzle_flash_timer = maxf(0.0, muzzle_flash_timer - delta)
	if heavy_flash_timer > 0.0:
		heavy_flash_timer = maxf(0.0, heavy_flash_timer - delta)
	if gun_recoil_offset > 0.0:
		gun_recoil_offset = maxf(0.0, gun_recoil_offset - delta * 45.0)
	camera_kick_ofs = camera_kick_ofs.move_toward(Vector2.ZERO, delta * 60.0)
	player_squash = player_squash.lerp(Vector2.ONE, delta * 14.0)

	# CRITICAL 3C RULE: Player movement, aiming, reloading & firing NEVER freeze during hitstop!
	# Only enemies and world time dilate slightly on heavy impacts so player controls stay 100% butter-smooth!
	var world_delta: float = delta
	if hitstop_timer > 0.0:
		hitstop_timer = maxf(0.0, hitstop_timer - delta)
		world_delta = delta * 0.18

	_handle_hotkeys()
	_update_player(delta)
	_update_weapons(delta)
	_update_enemies(world_delta)
	_update_black_holes(world_delta)
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
	for i in range(cryo_zones.size() - 1, -1, -1):
		cryo_zones[i]["timer"] -= delta
		if cryo_zones[i]["timer"] <= 0.0:
			cryo_zones.remove_at(i)


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

	if recoil_slide_vel.length_squared() > 1.0:
		player_pos += recoil_slide_vel * delta
		recoil_slide_vel = recoil_slide_vel.move_toward(Vector2.ZERO, delta * 1800.0)

	player_pos += player_vel * delta
	player_pos.x = clampf(player_pos.x, ARENA_RECT.position.x + PLAYER_RADIUS, ARENA_RECT.end.x - PLAYER_RADIUS)
	player_pos.y = clampf(player_pos.y, ARENA_RECT.position.y + PLAYER_RADIUS, ARENA_RECT.end.y - PLAYER_RADIUS)

	# Keep player out of solid deployed shield pylons
	for t in cover_tables:
		if t["flipped"] and t["hp"] > 0.0:
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


func _award_aegis_pip(reason: String) -> void:
	if aegis_shield >= max_aegis_shield:
		return
	aegis_pips += 1
	if aegis_pips >= 3:
		aegis_pips = 0
		aegis_shield = mini(max_aegis_shield, aegis_shield + 1)
		_play_sfx("perfect_reload", 1.18, 1.24)
		shockwaves.append({"pos": player_pos, "radius": 16.0, "max_r": 95.0, "timer": 0.30, "col": Color(0.2, 0.95, 1.0, 0.44)})
		_spawn_text(player_pos + Vector2(0, -48), "🛡️ 过载护盾重构完成! (3/3 Pips -> +1🛡️)", Color(0.2, 1.0, 0.95))
	else:
		_spawn_text(player_pos + Vector2(0, -44), "🛡️ 护盾重构进度 [%d/3] (%s)" % [aegis_pips, reason], Color(0.4, 0.9, 1.0))


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
		player_squash = Vector2(1.18, 0.85)
		if primary_idx == 0:
			gunslinger_crit_shots = 2
		elif primary_idx == 2:
			shotgun_bonus_pellets = 3
		var pitch_step := 1.0 + 0.08 * float(combat_perfect_reloads % 3)
		_play_sfx("perfect_reload", pitch_step, pitch_step + 0.03)
		if not room_cleared:
			_add_overcharge(CHARGE_PERFECT_RELOAD, "★ 完美换弹! +8⚡ (" + p_gun["sig_buff"] + ")")
			combat_perfect_reloads += 1
			if combat_perfect_reloads % 3 == 0:
				_award_aegis_pip("3次完美换弹")
		else:
			_spawn_text(player_pos + Vector2(0, -34), "★ 完美换弹! (已清房脱战 +0⚡)", Color(1.0, 0.9, 0.3))
		screen_shake = 7.0
		_trigger_perfect_reload_effects()
	else:
		# Missed sweet spot -> slight jam penalty
		reload_jammed = true
		_play_sfx("jam", 0.95, 1.02)
		_spawn_text(player_pos + Vector2(0, -32), "卡壳延迟! (错过黄区)", Color(1.0, 0.35, 0.3))


func _trigger_perfect_reload_effects() -> void:
	var cleared: int = 0
	var shock_radius: float = 125.0 if primary_idx == 2 else (135.0 if _has_passive("shock_reload") else 85.0)
	shockwaves.append({"pos": player_pos, "radius": 18.0, "max_r": shock_radius, "timer": 0.28, "col": Color(1.0, 0.9, 0.25, 0.42)})
	if _has_passive("shell_magnet") and not room_cleared:
		bounty_chips += 4
	for b in bullets:
		if b["active"] and b["team"] == "enemy" and b["pos"].distance_to(player_pos) <= shock_radius:
			b["active"] = false
			cleared += 1
	if _has_passive("shock_reload") or primary_idx == 2:
		for e in enemies:
			if e["hp"] > 0.0 and e["pos"].distance_to(player_pos) <= shock_radius + 30.0:
				_damage_enemy(e, 26.0, false)
	if cleared >= 3 and _cur_dynamo()["id"] == "bullet_shatter" and not room_cleared:
		_add_overcharge(_cur_dynamo()["bonus"], "⚡神盾碎弹核心触发 +14⚡")


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
	var base_interval: float = p_gun["fire_interval"]
	if primary_idx == 1 and perfect_reload_buff_timer > 0.0:
		base_interval *= 0.65 # Overclock Cadence +35% fire rate!
	fire_cd = base_interval
	var aim_dir := (get_global_mouse_position() - player_pos).normalized()
	muzzle_flash_timer = 0.08 if is_final_round else 0.05
	gun_recoil_offset = 12.0 if is_final_round else 6.0

	# Eject spinning brass shell casing (Final Round ejects glowing red-hot casing)
	var eject_dir := aim_dir.rotated(deg_to_rad(randf_range(95.0, 135.0)))
	shells.append({"pos": player_pos - aim_dir * 4.0, "vel": eject_dir * randf_range(95.0, 155.0), "rot": randf() * TAU, "hot": is_final_round})
	if shells.size() > 75:
		shells.pop_front()

	var dmg_mult: float = forge_dmg_mult
	var spd_mult: float = 1.0
	if primary_idx == 0 and gunslinger_crit_shots > 0:
		gunslinger_crit_shots -= 1
		dmg_mult *= 1.40
		spd_mult = 2.0
	if is_final_round and _has_passive("final_amp"):
		dmg_mult *= 1.6

	if is_final_round:
		_play_sfx("final_round", 0.96, 1.04)
		screen_shake = 8.5
		camera_kick_ofs = -aim_dir * 6.5
		recoil_slide_vel = -aim_dir * 55.0 # 4px crisp snap
		_spawn_text(player_pos + Vector2(0, -34), "★ 尾弹重击 (FINAL ROUND)!", Color(1.0, 0.78, 0.2))
		if primary_idx == 0:
			_spawn_bullet(player_pos + aim_dir * 16.0, aim_dir * 960.0 * spd_mult, p_gun["damage"] * 2.5 * dmg_mult, "player", 9.0, true, true)
		elif primary_idx == 1:
			for angle_deg in [-14.0, 0.0, 14.0]:
				var dir := aim_dir.rotated(deg_to_rad(angle_deg))
				_spawn_bullet(player_pos + dir * 16.0, dir * 860.0, p_gun["damage"] * 1.9 * dmg_mult, "player", 7.0, true, true)
		else:
			# Bailiff Pump-Shotgun Dragon's Breath Final Round Cone
			for angle_deg in [-20.0, -10.0, 0.0, 10.0, 20.0]:
				var dir := aim_dir.rotated(deg_to_rad(angle_deg))
				_spawn_bullet(player_pos + dir * 16.0, dir * 820.0, p_gun["damage"] * 1.6 * dmg_mult, "player", 8.0, true, true)
		is_reloading = true
		reload_progress = 0.0
		reload_attempted = false
		reload_jammed = false
	else:
		_play_sfx("shoot", 0.94, 1.08)
		screen_shake = maxf(screen_shake, 2.0)
		camera_kick_ofs = -aim_dir * 2.0
		if primary_idx == 2:
			var p_count: int = 5 + shotgun_bonus_pellets
			shotgun_bonus_pellets = 0
			for i in range(p_count):
				var ang := deg_to_rad(-18.0 + float(i) * (36.0 / float(maxi(1, p_count - 1))))
				var dir := aim_dir.rotated(ang)
				_spawn_bullet(player_pos + dir * 16.0, dir * p_gun["bullet_speed"], p_gun["damage"] * dmg_mult, "player", 5.5, false, false)
		else:
			var spread_max := 0.0 if (primary_idx == 1 and perfect_reload_buff_timer > 0.0) else 0.04
			var dir := aim_dir.rotated(randf_range(-spread_max, spread_max))
			_spawn_bullet(player_pos + dir * 16.0, dir * p_gun["bullet_speed"] * spd_mult, p_gun["damage"] * dmg_mult, "player", 5.5, false, false)
		if ammo == 1:
			_play_sfx("hit", 1.35, 1.42) # Metallic pre-chamber click when 1 round left!


func _try_fire_heavy() -> void:
	if heavy_cd_timer > 0.0:
		return
	var h_gun := _cur_heavy()
	var cost: float = h_gun["cost"]
	if overcharge < cost:
		_play_sfx("jam", 1.1, 1.2)
		_spawn_text(player_pos + Vector2(0, -30), "超载能量不足! 需 %d⚡" % int(cost), Color(1.0, 0.35, 0.35))
		heavy_cd_timer = 0.25
		return

	overcharge -= cost
	heavy_cd_timer = h_gun["cd"]
	heavy_flash_timer = 0.28
	gun_recoil_offset = 14.0
	_play_sfx("heavy_fire", 0.92, 1.05)
	var aim_dir := (get_global_mouse_position() - player_pos).normalized()

	# Tier-3 Shooter Physical Recoil Slide (8px / 16px / 22px over ~0.08s) + Squash!
	recoil_slide_vel = -aim_dir * float(h_gun["recoil_px"])
	player_squash = Vector2(0.78, 1.20)
	camera_kick_ofs = -aim_dir * 15.0
	if not room_cleared:
		_award_aegis_pip("释放重火器")

	match h_gun["type"]:
		"swarm":
			screen_shake = 9.5
			_spawn_text(player_pos + Vector2(0, -36), "★ 蜂群追踪导弹! (-45⚡ | 后坐滑步)", Color(0.3, 0.95, 1.0))
			for i in range(5):
				var ang := deg_to_rad(-24.0 + i * 12.0)
				var dir := aim_dir.rotated(ang)
				_spawn_bullet(player_pos + dir * 18.0, dir * 560.0, 36.0 * forge_dmg_mult, "player", 7.0, false, false, true)
		"rail":
			screen_shake = 15.0
			hitstop_timer = 0.045
			_spawn_text(player_pos + Vector2(0, -36), "★ 超导轨道炮轰击! (-65⚡ | 强力后坐滑步)", Color(0.4, 1.0, 0.9))
			var beam_end := player_pos + aim_dir * 1100.0
			rail_beams.append({"start": player_pos + aim_dir * 16.0, "end": beam_end, "timer": 0.28})
			for e in enemies:
				if e["hp"] > 0.0:
					var closest := Geometry2D.get_closest_point_to_segment(e["pos"], player_pos, beam_end)
					if closest.distance_to(e["pos"]) <= e["radius"] + 20.0:
						_damage_enemy(e, 95.0 * forge_dmg_mult, true, true, aim_dir * 45.0)
			for bc in beacons:
				if bc["hp"] > 0.0:
					var c_pt := Geometry2D.get_closest_point_to_segment(bc["pos"], player_pos, beam_end)
					if c_pt.distance_to(bc["pos"]) <= 30.0:
						_damage_beacon(bc, 95.0)
		"black_hole":
			screen_shake = 17.5
			hitstop_timer = 0.055
			_spawn_text(player_pos + Vector2(0, -36), "★ 奇点黑洞降临! (-90⚡ | 巨型后坐反冲)", Color(0.85, 0.4, 1.0))
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


func _spawn_bullet(pos: Vector2, vel: Vector2, dmg: float, team: String, radius: float, is_final: bool, pierces: bool, homing: bool = false, is_piercing_shield: bool = false) -> void:
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
			b["shield_piercing"] = is_piercing_shield
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
		"grazed": false,
		"shield_piercing": is_piercing_shield
	})


func _update_bullets(delta: float) -> void:
	var graze_r := GRAZE_RADIUS * (1.25 if _has_passive("fleet_step") else 1.0)
	var max_graze: int = 2 + forge_graze_cap_bonus
	for b in bullets:
		if not b["active"]:
			continue

		var spd_scale: float = 1.0
		if b["team"] == "enemy":
			for cz in cryo_zones:
				if cz["pos"].distance_to(b["pos"]) <= 140.0:
					spd_scale = 0.50
					break

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

		b["pos"] += b["vel"] * delta * spd_scale
		if not ARENA_RECT.has_point(b["pos"]):
			b["active"] = false
			continue

		# Check deployed Aegis Shield Pylon collision
		for t in cover_tables:
			if t["flipped"] and t["hp"] > 0.0 and t["rect"].has_point(b["pos"]):
				if b["team"] == "enemy":
					t["hp"] -= 10.0
					b["active"] = false
					break

		if not b["active"]:
			continue

		# Check Ranged Hit-Trigger Arena Interactables (Volatile Fuel Drum / Cryo Tank / Refractor Prism) & Signal Beacons
		if b["team"] == "player":
			for bc in beacons:
				if bc["hp"] > 0.0 and bc["pos"].distance_to(b["pos"]) <= 26.0:
					_damage_beacon(bc, b["dmg"])
					if not b["pierces"]:
						b["active"] = false
					break
			if not b["active"]:
				continue
			for br in barrels:
				if br["alive"] and br["pos"].distance_to(b["pos"]) <= 22.0:
					_trigger_ranged_interactable(br, b["vel"].normalized())
					if not b["pierces"]:
						b["active"] = false
					break

		if not b["active"]:
			continue

		if b["team"] == "player":
			for e in enemies:
				if e["hp"] > 0.0 and e["pos"].distance_to(b["pos"]) <= e["radius"] + b["radius"]:
					var b_vel: Vector2 = b["vel"]
					var kb_vec: Vector2 = b_vel.normalized() * (28.0 if b["is_final"] else 5.0)
					_damage_enemy(e, b["dmg"], b["is_final"], true, kb_vec)
					if not b["pierces"]:
						b["active"] = false
						break
		else:
			# Enemy bullet -> Check Dodge Roll I-frame Graze first!
			var dist_to_player: float = b["pos"].distance_to(player_pos)
			var in_iframes: bool = is_dodging and dodge_timer <= DODGE_IFRAME_END
			if in_iframes and not b["grazed"] and dist_to_player <= graze_r and dodge_grazed_count < max_graze:
				b["grazed"] = true
				dodge_grazed_count += 1
				var g_pitch := 1.0 + 0.12 * float(dodge_grazed_count - 1)
				_play_sfx("graze", g_pitch, g_pitch + 0.03)
				_add_overcharge(CHARGE_DODGE_GRAZE, "★ 极限擦弹 [%d/%d]! +10⚡" % [dodge_grazed_count, max_graze])

			if dist_to_player <= PLAYER_RADIUS + b["radius"] - 2.0:
				if in_iframes:
					continue
				b["active"] = false
				_damage_player(1, b.get("shield_piercing", false))


func _damage_beacon(bc: Dictionary, amount: float) -> void:
	if bc["hp"] <= 0.0:
		return
	bc["hp"] -= amount
	bc["flash"] = 0.12
	_play_sfx("hit", 1.1, 1.25)
	_spawn_text(bc["pos"] + Vector2(0, -24), "信标 -%d" % int(amount), Color(0.3, 0.95, 1.0))
	if bc["hp"] <= 0.0:
		_play_sfx("explosion", 1.05, 1.2)
		shockwaves.append({"pos": bc["pos"], "radius": 20.0, "max_r": 120.0, "timer": 0.30, "col": Color(0.3, 0.95, 1.0, 0.44)})
		_spawn_text(bc["pos"], "★ 巨企信标已摧毁!", Color(1.0, 0.9, 0.2))


func _trigger_ranged_interactable(br: Dictionary, shot_dir: Vector2) -> void:
	var h_type: String = br.get("type", "fuel")
	if h_type == "prism":
		_play_sfx("perfect_reload", 1.2, 1.3)
		shockwaves.append({"pos": br["pos"], "radius": 14.0, "max_r": 80.0, "timer": 0.22, "col": Color(0.85, 0.4, 1.0, 0.40)})
		_spawn_text(br["pos"] + Vector2(0, -24), "★ 棱镜折射分裂! (x5 追踪激光)", Color(0.9, 0.5, 1.0))
		for i in range(5):
			var d := shot_dir.rotated(deg_to_rad(-60.0 + i * 30.0))
			_spawn_bullet(br["pos"] + d * 18.0, d * 680.0, 22.0, "player", 6.0, false, false, true)
		br["hp"] = br.get("hp", 3) - 1
		if br["hp"] <= 0:
			br["alive"] = false
		return

	br["alive"] = false
	_play_sfx("explosion", 0.9, 1.05)
	screen_shake = 14.0
	hitstop_timer = 0.035
	var hit_any: bool = false
	if h_type == "cryo":
		cryo_zones.append({"pos": br["pos"], "timer": 4.0})
		shockwaves.append({"pos": br["pos"], "radius": 24.0, "max_r": 140.0, "timer": 0.34, "col": Color(0.2, 0.9, 1.0, 0.42)})
		_spawn_text(br["pos"], "★ 深冷液氮罐爆裂! (全场50%减速区)", Color(0.3, 0.95, 1.0))
		for e in enemies:
			if e["hp"] > 0.0 and e["pos"].distance_to(br["pos"]) <= 140.0:
				hit_any = true
				_damage_enemy(e, 25.0, false, false, (e["pos"] - br["pos"]).normalized() * 20.0)
	else:
		shockwaves.append({"pos": br["pos"], "radius": 24.0, "max_r": 140.0, "timer": 0.34, "col": Color(1.0, 0.5, 0.15, 0.44)})
		for k in range(10):
			var ang := randf() * TAU
			debris_list.append({"pos": br["pos"], "vel": Vector2.RIGHT.rotated(ang) * randf_range(90.0, 220.0), "col": Color(0.95, 0.45, 0.15)})
		_spawn_text(br["pos"], "★ 高爆燃料罐轰炸!", Color(1.0, 0.55, 0.1))
		for b in bullets:
			if b["active"] and b["team"] == "enemy" and b["pos"].distance_to(br["pos"]) <= 135.0:
				b["active"] = false
		for e in enemies:
			if e["hp"] > 0.0 and e["pos"].distance_to(br["pos"]) <= 135.0:
				hit_any = true
				_damage_enemy(e, 65.0, true, false, (e["pos"] - br["pos"]).normalized() * 38.0)
	if hit_any and _cur_dynamo()["id"] == "barrel_kick" and not room_cleared:
		_add_overcharge(_cur_dynamo()["bonus"], "⚡战术机关核心触发 +22⚡")


func _damage_enemy(e: Dictionary, amount: float, is_final: bool, from_direct_shot: bool = false, knockback_vec: Vector2 = Vector2.ZERO) -> void:
	if e["hp"] <= 0.0:
		return
	var is_stunned: bool = e.get("stun_timer", 0.0) > 0.0
	var final_dmg: float = amount * (1.30 if is_stunned else 1.0)
	e["hp"] -= final_dmg
	e["flash"] = 0.12
	_play_sfx("hit", 0.9, 1.15)

	# Apply knockback & Final Round hitstop/stagger!
	var kb_res: float = 0.35 if e.get("is_elite", false) else 0.0
	if knockback_vec.length_squared() > 0.1:
		e["pos"] += knockback_vec * (1.0 - kb_res)
		e["pos"].x = clampf(e["pos"].x, ARENA_RECT.position.x + 22.0, ARENA_RECT.end.x - 22.0)
		e["pos"].y = clampf(e["pos"].y, ARENA_RECT.position.y + 22.0, ARENA_RECT.end.y - 22.0)
	if is_final:
		hitstop_timer = maxf(hitstop_timer, 0.03)
		e["fire_cd"] += 0.25

	var dmg_col := Color(1.0, 0.85, 0.2) if (is_final or final_dmg >= 30.0) else Color(0.95, 0.95, 1.0)
	var prefix := "★尾弹暴击 -" if is_final else ("暴击 -" if final_dmg >= 30.0 else "-")
	_spawn_text(e["pos"] + Vector2(randf_range(-16, 16), -22), "%s%d" % [prefix, int(final_dmg)], dmg_col)

	if from_direct_shot and not room_cleared:
		if is_final:
			_add_overcharge(CHARGE_FINAL_ROUND_HIT, "尾弹命中 +4⚡")
		else:
			_add_overcharge(CHARGE_NORMAL_HIT, "")

	# Elite / Boss Exclusive Weak-Point Interrupt!
	if e.get("is_elite", false) and e["windup"] > 0.0 and (is_final or final_dmg >= 25.0):
		e["windup"] = 0.0
		e["stun_timer"] = 1.8
		e["fire_cd"] = 2.0
		hitstop_timer = 0.045
		_play_sfx("perfect_reload", 1.15, 1.25)
		shockwaves.append({"pos": e["pos"], "radius": 14.0, "max_r": 85.0, "timer": 0.28, "col": Color(1.0, 0.25, 0.25, 0.42)})
		_add_overcharge(CHARGE_WEAKPOINT_INTERRUPT, "★ 精英弱点打断! +22⚡ (破防易伤1.8s)")
		_award_aegis_pip("弱点打断")

	if e["hp"] <= 0.0:
		_play_sfx("explosion", 1.1, 1.28)
		var base_dir := knockback_vec.normalized() if knockback_vec.length_squared() > 0.1 else Vector2.UP
		for k in range(8):
			var ang := base_dir.angle() + deg_to_rad(randf_range(-35.0, 35.0))
			debris_list.append({"pos": e["pos"], "vel": Vector2.RIGHT.rotated(ang) * randf_range(120.0, 290.0), "col": Color(0.55, 0.6, 0.68)})
		while debris_list.size() > 45:
			debris_list.pop_front()
		var chip_drop: int = (25 if e.get("is_elite", false) else 10) * (2 if active_overdrive_bet else 1)
		bounty_chips += chip_drop
		_spawn_text(e["pos"], "+%d 🪙悬赏工分币" % chip_drop, Color(1.0, 0.88, 0.3))
		if elapsed_time - last_kill_time <= 3.0 and _cur_dynamo()["id"] == "kill_chain" and not room_cleared:
			_add_overcharge(_cur_dynamo()["bonus"], "⚡狂暴连杀核心 +6⚡")
		last_kill_time = elapsed_time


func _damage_player(dmg: int, is_shield_piercing: bool = false) -> void:
	if invuln_timer > 0.0:
		return
	invuln_timer = 1.0
	_play_sfx("jam", 0.75, 0.85)
	screen_shake = 14.0
	if aegis_shield > 0 and not is_shield_piercing:
		aegis_shield -= 1
		# Aegis-Break Blank (90px bullet clear!)
		for b in bullets:
			if b["active"] and b["team"] == "enemy" and b["pos"].distance_to(player_pos) <= 95.0:
				b["active"] = false
		shockwaves.append({"pos": player_pos, "radius": 18.0, "max_r": 95.0, "timer": 0.28, "col": Color(0.2, 0.9, 1.0, 0.44)})
		_spawn_text(player_pos + Vector2(0, -34), "🛡️ 过载护盾碎裂震波! (保住无伤金身 | 攒3格重构点可恢复)", Color(0.3, 0.95, 1.0))
	else:
		hp = maxi(1, hp - dmg)
		if is_shield_piercing:
			_spawn_text(player_pos + Vector2(0, -34), "⚠️ 破盾穿甲重击! 直接 -1 ❤️生命!", Color(1.0, 0.15, 0.45))
		else:
			_spawn_text(player_pos + Vector2(0, -30), "受击 -1 ❤️生命!", Color(1.0, 0.25, 0.25))


func _add_overcharge(amount: float, label: String) -> void:
	overcharge = clampf(overcharge + amount, 0.0, max_overcharge)
	if label != "":
		_spawn_text(player_pos + Vector2(randf_range(-24, 24), -42), label, Color(0.3, 1.0, 0.85))


func _update_enemies(delta: float) -> void:
	if not room_cleared and room_objective == "OVERDRIVE_SURVIVAL":
		survival_timer = maxf(0.0, survival_timer - delta)

	var speed_mult: float = 1.25 if active_overdrive_bet else 1.0
	for e in enemies:
		if e["hp"] <= 0.0:
			continue
		if e["flash"] > 0.0:
			e["flash"] -= delta
		if e.get("stun_timer", 0.0) > 0.0:
			e["stun_timer"] -= delta
			continue

		var cryo_mult: float = 1.0
		for cz in cryo_zones:
			if cz["pos"].distance_to(e["pos"]) <= 140.0:
				cryo_mult = 0.50
				break

		var to_player: Vector2 = player_pos - e["pos"]
		var dist: float = to_player.length()
		if dist > 160.0:
			e["pos"] += to_player.normalized() * e["speed"] * cryo_mult * delta
		elif dist < 100.0:
			e["pos"] -= to_player.normalized() * e["speed"] * 0.6 * cryo_mult * delta

		if e["windup"] > 0.0:
			e["windup"] -= delta * cryo_mult
			if e["windup"] <= 0.0:
				_enemy_fire(e, speed_mult * cryo_mult)
		else:
			e["fire_cd"] -= delta * cryo_mult
			if e["fire_cd"] <= 0.0:
				if e.get("is_elite", false):
					e["windup"] = 0.85 # Elite/Boss Exclusive Weak-Point Interrupt window!
					e["fire_cd"] = e["cadence"]
				else:
					# Fodder mobs fire directly with zero interrupt reticle clutter!
					_enemy_fire(e, speed_mult * cryo_mult)
					e["fire_cd"] = e["cadence"]


func _enemy_fire(e: Dictionary, speed_mult: float) -> void:
	var aim: Vector2 = (player_pos - e["pos"]).normalized()
	var is_piercing_sig: bool = e.get("is_elite", false)
	match e["archetype"]:
		"burst":
			for ang_deg in [-18.0, 0.0, 18.0]:
				var d := aim.rotated(deg_to_rad(ang_deg))
				_spawn_bullet(e["pos"], d * 250.0 * speed_mult, 1.0, "enemy", 6.5, false, false, false, is_piercing_sig)
		"ring":
			for i in range(8):
				var d := Vector2.RIGHT.rotated(TAU * float(i) / 8.0)
				_spawn_bullet(e["pos"], d * 210.0 * speed_mult, 1.0, "enemy", 6.5, false, false, false, is_piercing_sig)
		"sniper":
			_spawn_bullet(e["pos"], aim * 370.0 * speed_mult, 1.0, "enemy", 8.0, false, false, false, is_piercing_sig)


func _check_room_state() -> void:
	if room_cleared:
		return

	var obj_done: bool = false
	if room_objective == "SABOTAGE_BEACONS":
		obj_done = true
		for bc in beacons:
			if bc["hp"] > 0.0:
				obj_done = false
				break
	elif room_objective == "OVERDRIVE_SURVIVAL":
		if survival_timer <= 0.0:
			obj_done = true
		else:
			var any_alive := false
			for e in enemies:
				if e["hp"] > 0.0:
					any_alive = true
					break
			if not any_alive:
				obj_done = true
	else:
		obj_done = true
		for e in enemies:
			if e["hp"] > 0.0:
				obj_done = false
				break

	if not obj_done:
		return

	room_cleared = true
	# Hades-Style Chamber Clear Shockwave: Instantly vaporize remaining fodder & enemy bullets!
	_play_sfx("perfect_reload", 1.05, 1.15)
	shockwaves.append({"pos": player_pos, "radius": 30.0, "max_r": 650.0, "timer": 0.40, "col": Color(0.3, 1.0, 0.9, 0.35)})
	for e in enemies:
		if e["hp"] > 0.0:
			e["hp"] = 0.0
	for b in bullets:
		if b["active"] and b["team"] == "enemy":
			b["active"] = false
	_spawn_text(player_pos + Vector2(0, -48), "★ 房间目标达成! 全场敌军脉冲清零!", Color(0.3, 1.0, 0.85))
	_spawn_three_category_doors()


func _spawn_three_category_doors() -> void:
	# Spatially Distributed Hades-Style Exits (North-West, North-East, and East Wall Sockets!)
	doors = [
		{
			"cat": "armory",
			"title": "↖【1】军械库门 (枪械门)",
			"subtitle": "掉落：主武器/重火器/核心 (押注保底蓝冲金)",
			"rect": Rect2(140.0, 92.0, 250.0, 54.0),
			"bet": false,
			"color": Color(1.0, 0.68, 0.15)
		},
		{
			"cat": "item",
			"title": "↗【2】战术道具门 (道具门)",
			"subtitle": "掉落：四阶稀有度芯片 (上限3槽)",
			"rect": Rect2(640.0, 92.0, 250.0, 54.0),
			"bet": false,
			"color": Color(0.2, 0.9, 1.0)
		},
		{
			"cat": "event",
			"title": "➡【3】奇遇与整备门 (东侧出口)",
			"subtitle": "老雷克斯盲盒黑市 / 巴克四维铁匠铺",
			"rect": Rect2(955.0, 285.0, 240.0, 58.0),
			"bet": false,
			"color": Color(0.85, 0.42, 1.0)
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
					_spawn_text(d["rect"].get_center(), "★ 超载押注锁定! (-25⚡ -> 下房双倍🪙 & 0%白装保底蓝紫金!)", Color(1.0, 0.35, 0.2))
				else:
					_play_sfx("jam", 1.0, 1.05)
					_spawn_text(player_pos + Vector2(0, -30), "超载押注需要 25⚡ 能量!", Color(1.0, 0.4, 0.4))


func _on_interact_pressed() -> void:
	# Proximity [E] Tactical Arena Interactables (Deployable Shield Pylon & Overcharge Capacitor Tap-Box)
	for t in cover_tables:
		if not t["flipped"] and t["hp"] > 0.0 and t["rect"].grow(40.0).has_point(player_pos):
			t["flipped"] = true
			_play_sfx("hit", 0.75, 0.85)
			screen_shake = 6.0
			if t.get("type", "shield") == "capacitor":
				t["hp"] = 0.0
				_add_overcharge(22.0, "★ 扯断高压偷电箱! +22⚡ & 震慑电弧!")
				shockwaves.append({"pos": t["rect"].get_center(), "radius": 18.0, "max_r": 115.0, "timer": 0.30, "col": Color(0.2, 0.95, 1.0, 0.44)})
				for e in enemies:
					if e["hp"] > 0.0 and e["pos"].distance_to(t["rect"].get_center()) <= 115.0:
						e["stun_timer"] = 1.5
						_damage_enemy(e, 24.0, false)
			else:
				_spawn_text(t["rect"].get_center(), "★ 升起液压防爆盾! (阻挡弹幕 & 震消周围敌弹)", Color(0.3, 0.95, 1.0))
				var cleared: int = 0
				for b in bullets:
					if b["active"] and b["team"] == "enemy" and t["rect"].grow(28.0).has_point(b["pos"]):
						b["active"] = false
						cleared += 1
				if cleared >= 3 and _cur_dynamo()["id"] == "bullet_shatter" and not room_cleared:
					_add_overcharge(_cur_dynamo()["bonus"], "⚡神盾碎弹核心触发 +14⚡")
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
			primary_idx = (primary_idx + 1) % primary_weapons.size()
			ammo = _cur_primary()["mag_size"]
			heavy_idx = (heavy_idx + 1) % heavy_weapons.size()
			current_event_popup = "【军械门奖励】切换主枪 -> %s | 重火器 -> %s" % [_cur_primary()["name"], _cur_heavy()["name"]]
		"item":
			_grant_item_door_reward(bet)
		"event":
			_trigger_random_event_room()

	_setup_room(room_number, cat, bet)


func _grant_item_door_reward(bet: bool) -> void:
	var pool: Array[Dictionary] = [
		{"id": "wide_sweet", "name": "时序滑块卡扣 [军规·蓝]", "rarity": "RARE", "salvage": 25, "desc": "拓宽主动换弹的黄色完美甜区 (+8%)"},
		{"id": "final_amp", "name": "欧米茄强化撞针 [违禁·紫]", "rarity": "EPIC", "salvage": 40, "desc": "尾弹(Final Round)额外 +60% 暴击伤害与击退"},
		{"id": "over_cap", "name": "高压电容线圈 [违禁·紫]", "rarity": "EPIC", "salvage": 40, "desc": "最大超载能量上限提升至 130⚡"},
		{"id": "shell_magnet", "name": "财务催收磁铁 [超载·金]", "rarity": "LEGENDARY", "salvage": 65, "desc": "战斗完美换弹额外 +4🪙 & 拆解收益+50%"}
	]
	var candidate: Dictionary = pool[randi() % pool.size()]
	var salv_val: int = candidate["salvage"]
	if _has_passive(candidate["id"]):
		bounty_chips += salv_val
		current_event_popup = "【道具门】重复芯片自动核销 -> 获得 +%d 🪙悬赏工分币!" % salv_val
		return

	if passive_items.size() < PASSIVE_CAP:
		passive_items.append(candidate)
		if candidate["id"] == "over_cap":
			max_overcharge = 130.0
		current_event_popup = "【道具门%s】获得 %s (%s)" % ["·押注保底高罕!" if bet else "", candidate["name"], candidate["desc"]]
	else:
		pending_passive_offer = candidate
		current_event_popup = "【被动槽满 3/3】按 [7]/[8]/[9] 替换旧芯片并拆解(+%d🪙) -> 新芯片：%s" % [salv_val, candidate["name"]]


func _resolve_passive_swap(slot_index: int) -> void:
	if pending_passive_offer.is_empty() or slot_index < 0 or slot_index >= passive_items.size():
		return
	var old_item := passive_items[slot_index]
	var salv_val: int = old_item.get("salvage", 25)
	passive_items[slot_index] = pending_passive_offer
	bounty_chips += salv_val
	_play_sfx("perfect_reload", 1.05, 1.1)
	current_event_popup = "已替换 [%s] -> [%s] (旧件核销 +%d 🪙悬赏工分币!)" % [old_item["name"], pending_passive_offer["name"], salv_val]
	pending_passive_offer = {}


func _trigger_random_event_room() -> void:
	var roll: int = randi() % 3
	if roll == 0:
		# Bucky's Multi-Axis Forge (Strict +1 HP heal + Weapon/Exoskeleton tuning)
		hp = mini(max_hp, hp + 1)
		forge_dmg_mult += 0.15
		forge_graze_cap_bonus = 1
		current_event_popup = "【巴克铁匠铺·四维调校】恢复 +1 ❤️生命(严控上限) + 膛压强化(+15%伤害) + 外骨骼擦弹上限提升至 3次/滚!"
	elif roll == 1:
		# Old Rex's Mystery Contraband Blind Box (60 Bounty Chips)
		if bounty_chips >= 60:
			bounty_chips -= 60
			overcharge = max_overcharge
			bounty_chips += 110
			current_event_popup = "【老雷克斯黑市·60🪙走私盲盒】开出金色大奖! 超载能量充满 100% + 爆出 110 🪙悬赏工分币!"
		else:
			bounty_chips += 45
			current_event_popup = "【算盘姐支线委托】预支悬赏经费 -> 获得 +45 🪙悬赏工分币 & 补充 +1 格护盾重构点!"
			_award_aegis_pip("算盘姐支线")
	else:
		# Rival Vesper Quota Bet
		bounty_chips += 55
		_award_aegis_pip("铁匠铺充能")
		current_event_popup = "【奇遇·卷王薇拉的赌局】接下绩效挑战 -> 入账 +55 🪙悬赏工分币 & 护盾重构点 +1!"


func _setup_room(r_num: int, _cat: String, bet: bool) -> void:
	room_cleared = false
	active_overdrive_bet = bet
	bullets.clear()
	enemies.clear()
	black_holes.clear()
	cryo_zones.clear()
	beacons.clear()
	doors.clear()
	player_pos = Vector2(640.0, 560.0)
	# Note: Overcharge Aegis Shield does NOT auto-refill on room entry! Must be earned via 3 Aegis Pips!

	# Cycle through the Differentiated Room Objective Modes!
	if r_num % 3 == 2:
		room_objective = "SABOTAGE_BEACONS"
		beacons = [
			{"pos": Vector2(210.0, 185.0), "hp": 110.0, "max_hp": 110.0, "flash": 0.0},
			{"pos": Vector2(640.0, 155.0), "hp": 110.0, "max_hp": 110.0, "flash": 0.0},
			{"pos": Vector2(1060.0, 215.0), "hp": 110.0, "max_hp": 110.0, "flash": 0.0}
		]
	elif r_num % 3 == 0:
		room_objective = "OVERDRIVE_SURVIVAL"
		survival_timer = 22.0
	else:
		room_objective = "EXTERMINATION"

	# Proximity [E] Interactables: Left = Deployable Shield Pylon, Right = Overcharge Tap-Box Capacitor
	cover_tables = [
		{"rect": Rect2(340.0, 350.0, 96.0, 34.0), "flipped": false, "hp": 60.0, "type": "shield"},
		{"rect": Rect2(830.0, 350.0, 88.0, 34.0), "flipped": false, "hp": 60.0, "type": "capacitor"}
	]
	# Ranged Hit-Trigger Interactables: Left = Volatile Fuel Drum, Mid = Refractor Prism, Right = Cryo-Coolant Tank
	barrels = [
		{"pos": Vector2(460.0, 255.0), "alive": true, "type": "fuel", "label": "高爆燃料罐"},
		{"pos": Vector2(640.0, 285.0), "alive": true, "type": "prism", "hp": 3, "label": "折射棱镜柱"},
		{"pos": Vector2(820.0, 255.0), "alive": true, "type": "cryo", "label": "深冷液氮罐"}
	]

	var count: int = 3 + mini(r_num, 3) + (1 if bet else 0)
	var archetypes := ["burst", "ring", "sniper"]
	for i in range(count):
		var arch: String = archetypes[i % archetypes.size()]
		var is_elite_mob: bool = (i == 0) # Exactly 1 Elite Commander per room with Weak-Point Interrupt & Shield-Piercing signature!
		var base_hp: float = (175.0 if is_elite_mob else 85.0) + r_num * 12.0
		enemies.append({
			"pos": Vector2(240.0 + i * (780.0 / float(maxi(1, count - 1))), randf_range(165.0, 245.0)),
			"hp": base_hp,
			"max_hp": base_hp,
			"speed": 75.0,
			"radius": 24.0 if is_elite_mob else 17.0,
			"archetype": arch,
			"is_elite": is_elite_mob,
			"stun_timer": 0.0,
			"cadence": 2.1 if is_elite_mob else 1.85,
			"fire_cd": 0.9 + i * 0.35,
			"windup": 0.0,
			"flash": 0.0
		})


func _spawn_text(pos: Vector2, txt: String, col: Color) -> void:
	if floating_texts.size() >= 18:
		floating_texts.pop_front()
	floating_texts.append({"pos": pos, "text": txt, "color": col, "timer": 0.85})


func _update_floating_texts(delta: float) -> void:
	for i in range(floating_texts.size() - 1, -1, -1):
		floating_texts[i]["timer"] -= delta
		floating_texts[i]["pos"].y -= 28.0 * delta
		if floating_texts[i]["timer"] <= 0.0:
			floating_texts.remove_at(i)


func _draw() -> void:
	var raw_shake := camera_kick_ofs + Vector2(randf_range(-screen_shake, screen_shake), randf_range(-screen_shake, screen_shake))
	var shake_ofs := raw_shake.limit_length(18.0)
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

	# 1.5 Draw Floor Shell Casings, Debris & Cryo Zones (Alpha <= 45%)
	for cz in cryo_zones:
		draw_circle(cz["pos"], 140.0, Color(0.15, 0.85, 1.0, 0.22))
		draw_arc(cz["pos"], 140.0, 0.0, TAU, 40, Color(0.3, 0.95, 1.0, 0.42), 2.5)
	for s in shells:
		var s_col := Color(1.0, 0.45, 0.15, 0.95) if s.get("hot", false) else Color(0.92, 0.72, 0.22, 0.85)
		var s_sz := Vector2(8, 4) if s.get("hot", false) else Vector2(6, 3)
		draw_rect(Rect2(s["pos"] - s_sz * 0.5, s_sz), s_col)
	for d in debris_list:
		draw_rect(Rect2(d["pos"].x - 3, d["pos"].y - 3, 6, 6), d["col"])

	# 2. Draw Distributed Hades-Style Doors when Room is Cleared
	for d in doors:
		var r: Rect2 = d["rect"]
		var col: Color = d["color"]
		draw_rect(r, col.darkened(0.68))
		draw_rect(r, col, false, 3.0 if not d["bet"] else 5.0)
		draw_string(font, r.position + Vector2(10, 22), d["title"], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, col.lightened(0.3))
		draw_string(font, r.position + Vector2(10, 42), d["subtitle"], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)
		if d["bet"]:
			draw_string(font, r.position + Vector2(6, -8), "★ 已锁超载押注 (2x🪙 & 保底蓝冲金!)", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1.0, 0.35, 0.2))
		elif d["cat"] != "event":
			draw_string(font, r.position + Vector2(6, -8), "[E] 进门  [F] 押注25⚡(0%白装)", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.8, 0.9, 1.0))
		else:
			draw_string(font, r.position + Vector2(6, -8), "[E] 进入黑市/铁匠铺/奇遇", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.9, 0.75, 1.0))

	# 2.5 Draw Corporate Signal Beacons (if SABOTAGE_BEACONS room mode)
	for bc in beacons:
		if bc["hp"] <= 0.0:
			continue
		var b_pos: Vector2 = bc["pos"]
		draw_circle(b_pos, 24.0, Color(0.15, 0.85, 1.0, 0.35))
		draw_rect(Rect2(b_pos - Vector2(14, 18), Vector2(28, 36)), Color(0.2, 0.95, 1.0) if bc["flash"] <= 0.0 else Color.WHITE)
		draw_rect(Rect2(b_pos - Vector2(14, 18), Vector2(28, 36)), Color.BLACK, false, 2.0)
		var b_pct := clampf(bc["hp"] / bc["max_hp"], 0.0, 1.0)
		draw_rect(Rect2(b_pos.x - 22, b_pos.y - 30, 44 * b_pct, 5), Color(0.2, 1.0, 0.95))
		draw_string(font, b_pos + Vector2(-38, -36), "📡巨企信标 (击破清场)", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.4, 1.0, 0.95))

	# 3. Draw Proximity [E] & Ranged Hit-Trigger Tactical Arena Interactables
	for t in cover_tables:
		if t["hp"] <= 0.0:
			continue
		var is_cap: bool = (t.get("type", "shield") == "capacitor")
		var col := (Color(0.2, 0.65, 0.85) if is_cap else Color(0.32, 0.38, 0.48)) if not t["flipped"] else Color(0.2, 0.92, 1.0)
		draw_rect(t["rect"], col)
		draw_rect(t["rect"], Color.BLACK, false, 2.0)
		var lbl := ("[E] 扯断偷电箱(+22⚡)" if is_cap else "[E] 升起防爆盾桩") if not t["flipped"] else ("防爆盾 (%d)" % int(t["hp"]))
		draw_string(font, t["rect"].position + Vector2(4, 22), lbl, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)

	for br in barrels:
		if br["alive"]:
			var btype: String = br.get("type", "fuel")
			var out_c := Color(0.85, 0.25, 0.15) if btype == "fuel" else (Color(0.15, 0.75, 0.95) if btype == "cryo" else Color(0.75, 0.3, 0.95))
			var in_c := Color(1.0, 0.65, 0.1) if btype == "fuel" else (Color(0.7, 0.98, 1.0) if btype == "cryo" else Color(1.0, 0.75, 1.0))
			draw_circle(br["pos"], 16.0, out_c)
			draw_circle(br["pos"], 10.0, in_c)
			draw_string(font, br["pos"] + Vector2(-28, -20), br.get("label", "机关"), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, in_c.lightened(0.2))

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

	# 5. Draw Enemies (Fodder Mobs have ZERO interrupt clutter; Elites have Red-Flash Shield-Piercing Interrupt Window!)
	for e in enemies:
		if e["hp"] <= 0.0:
			continue
		var is_el: bool = e.get("is_elite", false)
		if is_el:
			draw_arc(e["pos"], e["radius"] + 5.0, 0.0, TAU, 28, Color(1.0, 0.78, 0.15, 0.75), 2.0)
		if is_el and e["windup"] > 0.0:
			draw_circle(e["pos"], e["radius"] + 16.0, Color(1.0, 0.1, 0.35, 0.38))
			draw_string(font, e["pos"] + Vector2(-72, -34), "⚠️精英穿甲蓄力! 尾弹/重火器打断(+22⚡)", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1.0, 0.88, 0.2))
		elif e.get("stun_timer", 0.0) > 0.0:
			draw_string(font, e["pos"] + Vector2(-36, -34), "💫破防瘫痪 (+30%易伤)", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.3, 0.95, 1.0))

		var etex: Texture2D = tex_enemy_burst
		if e["archetype"] == "ring":
			etex = tex_enemy_ring
		elif e["archetype"] == "sniper":
			etex = tex_enemy_sniper

		var mod_col := Color(3.0, 3.0, 3.0, 1.0) if e["flash"] > 0.0 else (Color(1.2, 0.95, 0.4, 1.0) if is_el else Color.WHITE)
		if etex != null:
			var sz := etex.get_size() * (1.35 if is_el else 1.0)
			draw_texture_rect(etex, Rect2(e["pos"] - sz * 0.5, sz), false, mod_col)
		else:
			draw_circle(e["pos"], e["radius"], Color.WHITE if e["flash"] > 0.0 else Color(0.95, 0.32, 0.32))

		var hp_pct: float = clampf(e["hp"] / e["max_hp"], 0.0, 1.0)
		var bar_w: float = 52.0 if is_el else 38.0
		draw_rect(Rect2(e["pos"].x - bar_w * 0.5, e["pos"].y - 28, bar_w, 5), Color(0.2, 0.2, 0.2))
		draw_rect(Rect2(e["pos"].x - bar_w * 0.5, e["pos"].y - 28, bar_w * hp_pct, 5), Color(1.0, 0.75, 0.15) if is_el else Color(1.0, 0.3, 0.3))

	# 6. Draw Player Afterimages, Dodge Graze Ring, Overcharge Aegis Shield Ring, Animated Pixel Sheet & Gun Sprite
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
		draw_arc(player_pos, graze_r, 0.0, TAU, 36, Color(0.2, 0.7, 0.9, 0.16), 1.0)

	if aegis_shield > 0:
		draw_arc(player_pos, 22.0, 0.0, TAU, 6, Color(0.2, 0.95, 1.0, 0.55), 2.0)

	var aim_dir := (get_global_mouse_position() - player_pos).normalized()
	if tex_player != null:
		var moving: bool = player_vel.length_squared() > 20.0
		var frame_idx: int = int(elapsed_time * (12.0 if moving else 4.0)) % 4
		var src_rect := Rect2(frame_idx * 48.0, 0.0, 48.0, 36.0)
		var dst_size := Vector2(48.0 * player_squash.x, 36.0 * player_squash.y)
		if is_dodging:
			dst_size = Vector2(54.0, 30.0)
		var p_mod := Color(0.5, 1.0, 1.0, 1.0) if in_iframes else Color.WHITE
		draw_texture_rect_region(tex_player, Rect2(player_pos - dst_size * 0.5, dst_size), src_rect, p_mod)
	else:
		draw_circle(player_pos, PLAYER_RADIUS, Color(0.2, 1.0, 0.95) if in_iframes else Color(0.3, 0.85, 0.45))

	# Draw Handcrafted Rotated Gun Sprite + Recoil + Golden Cross Final Round Muzzle Flash
	var gun_tex: Texture2D = tex_gun_heavy if heavy_flash_timer > 0.0 else (tex_gun_revolver if primary_idx == 0 else tex_gun_smg)
	var gun_pos := player_pos + aim_dir * (16.0 - gun_recoil_offset)
	if gun_tex != null:
		draw_set_transform(shake_ofs + gun_pos, aim_dir.angle(), Vector2.ONE)
		var gsz := gun_tex.get_size()
		draw_texture_rect(gun_tex, Rect2(-gsz * 0.3, gsz), false)
		if muzzle_flash_timer > 0.0 or heavy_flash_timer > 0.20:
			var f_rad := 14.0 if muzzle_flash_timer > 0.06 else 9.0
			draw_circle(Vector2(gsz.x * 0.7, 0), f_rad, Color(1.0, 0.88, 0.2, 0.92))
			draw_circle(Vector2(gsz.x * 0.7, 0), f_rad * 0.5, Color.WHITE)
		draw_set_transform(shake_ofs, 0.0, Vector2.ONE)
	else:
		draw_line(player_pos, gun_pos + aim_dir * 12.0, Color.WHITE, 3.5)

	# 7. Overhead Weapon-Specific Active Reload Slider Bar (Micro-UI directly above player)
	if is_reloading:
		var bar_y_ofs: float = 28.0 if player_pos.y < 135.0 else -38.0
		var bar_pos := player_pos + Vector2(-38, bar_y_ofs)
		var bar_w: float = 76.0
		var p_gun := _cur_primary()
		var s_start: float = p_gun["sweet_start"]
		var s_end: float = minf(0.92, p_gun["sweet_end"] + (0.08 if _has_passive("wide_sweet") else 0.0))
		draw_rect(Rect2(bar_pos.x, bar_pos.y, bar_w, 8), Color(0.12, 0.13, 0.16))
		draw_rect(Rect2(bar_pos.x + bar_w * s_start, bar_pos.y, bar_w * (s_end - s_start), 8), Color(1.0, 0.88, 0.15) if not reload_jammed else Color(0.65, 0.25, 0.25))
		var cursor_x := bar_pos.x + bar_w * clampf(reload_progress, 0.0, 1.0)
		draw_line(Vector2(cursor_x, bar_pos.y - 3), Vector2(cursor_x, bar_pos.y + 11), Color.WHITE, 3.0)
		draw_string(font, bar_pos + Vector2(-8, -5), "[R] 完美换弹 (+8⚡ & 武器专属Buff)", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1.0, 0.9, 0.3))
	elif ammo == 1:
		draw_string(font, player_pos + Vector2(-28, -32), "★ 尾弹待发!", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1.0, 0.82, 0.2))

	# 8. Draw Pooled Projectiles (Enemy bullets on top layer Z=40 with white core + bright red/violet rim)
	for b in bullets:
		if not b["active"]:
			continue
		if b["team"] == "player":
			var bcol := Color(1.0, 0.82, 0.2) if b["is_final"] else (Color(0.4, 1.0, 0.85) if b["homing"] else Color(0.35, 0.95, 1.0))
			draw_circle(b["pos"], b["radius"], bcol)
			draw_circle(b["pos"], b["radius"] * 0.5, Color.WHITE)
		else:
			var rim_col := Color(1.0, 0.05, 0.55) if b.get("shield_piercing", false) else Color(1.0, 0.12, 0.22)
			draw_circle(b["pos"], b["radius"] + 2.5, rim_col)
			draw_circle(b["pos"], b["radius"] * 0.55, Color.WHITE)

	# 9. Floating Combat Callouts
	for ft in floating_texts:
		draw_string(font, ft["pos"], ft["text"], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, ft["color"])

	# 10. Top & Bottom HUD (7-Slot Loadout + 3-Pip Aegis Shield + 4-Mode Room Objective + 45/65/90⚡ Gauge)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_draw_hud(font)


func _draw_hud(font: Font) -> void:
	draw_rect(Rect2(0, 0, 1280, 86), Color(0.05, 0.06, 0.08, 0.95))
	var pip_str := "[%s][%s][%s]" % ["■" if aegis_pips >= 1 else "□", "■" if aegis_pips >= 2 else "□", "■" if aegis_pips >= 3 else "□"]
	var shield_txt := "🛡️过载盾: %d/%d (重构:%s)" % [aegis_shield, max_aegis_shield, "已满" if aegis_shield >= max_aegis_shield else pip_str]
	draw_string(font, Vector2(18, 25), "房间 #%d  ❤️生命:%d/%d  %s  🪙赏金币:%d" % [room_number, hp, max_hp, shield_txt, bounty_chips], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)

	# Overcharge Gauge with 45 / 65 / 90⚡ Threshold Notches
	var oc_pct := clampf(overcharge / max_overcharge, 0.0, 1.0)
	var h_cost: float = _cur_heavy()["cost"]
	var ready_heavy: bool = (overcharge >= h_cost and heavy_cd_timer <= 0.0)
	draw_rect(Rect2(475, 7, 320, 22), Color(0.18, 0.2, 0.25))
	draw_rect(Rect2(475, 7, 320 * oc_pct, 22), Color(1.0, 0.82, 0.2) if ready_heavy else Color(0.25, 0.95, 0.85))
	for tick_val in [45.0, 65.0, 90.0]:
		var tx: float = 475.0 + 320.0 * (tick_val / max_overcharge)
		draw_line(Vector2(tx, 7), Vector2(tx, 29), Color(0.05, 0.06, 0.08), 2.0)
	var cd_suffix := (" [冷却%.1fs]" % heavy_cd_timer) if heavy_cd_timer > 0.0 else (" [右键可轰击!]" if ready_heavy else "")
	var oc_label := "⚡超载: %d/%d (重火器:%d⚡%s)" % [int(overcharge), int(max_overcharge), int(h_cost), cd_suffix]
	draw_string(font, Vector2(482, 23), oc_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.BLACK if oc_pct > 0.35 else Color.WHITE)

	# Top-Right Dynamic Room Objective Tracker!
	var obj_str := ""
	if room_cleared:
		obj_str = "✅ 房间已清空! 请选择出口大门 ([F]可押注25⚡)"
	elif room_objective == "SABOTAGE_BEACONS":
		var b_alive: int = 0
		for bc in beacons:
			if bc["hp"] > 0.0:
				b_alive += 1
		obj_str = "📡 任务【破坏信标】: 剩余 %d/3 座 (击破即全屏秒杀清场!)" % b_alive
	elif room_objective == "OVERDRIVE_SURVIVAL":
		obj_str = "⏱️ 任务【高压生存】: 坚持 %.1f 秒 (时间到即全场自爆!)" % survival_timer
	else:
		var e_alive: int = 0
		for e in enemies:
			if e["hp"] > 0.0:
				e_alive += 1
		obj_str = "👾 任务【歼灭战】: 剩余敌军 %d (含1名精英督察)" % e_alive
	draw_string(font, Vector2(810, 25), obj_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1.0, 0.88, 0.25) if not room_cleared else Color(0.3, 1.0, 0.75))

	var buff_str := (" | ★专属Buff激活(%.1fs): %s" % [perfect_reload_buff_timer, _cur_primary()["sig_buff"]]) if perfect_reload_buff_timer > 0.0 else ""
	draw_string(font, Vector2(18, 50), "【军械3槽】(按Z/X/1-3随时切换体验) -> 左键:%s (弹匣:%d/%d) | 右键:%s | 核心:%s%s" % [_cur_primary()["name"], ammo, _cur_primary()["mag_size"], _cur_heavy()["name"], _cur_dynamo()["name"], buff_str], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.88, 0.94, 1.0))

	var p_names: Array[String] = []
	for p in passive_items:
		p_names.append(p["name"])
	var cd_txt := "就绪[按Q]" if active_item["timer"] <= 0.0 else ("%.1fs" % active_item["timer"])
	draw_string(font, Vector2(18, 73), "【战术道具4槽】-> 主动(1/1): %s(%s) | 被动(%d/3): %s" % [active_item["name"], cd_txt, passive_items.size(), "、".join(p_names)], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.6, 1.0, 0.75))

	draw_rect(Rect2(0, 654, 1280, 66), Color(0.05, 0.06, 0.08, 0.95))
	if current_event_popup != "":
		draw_string(font, Vector2(18, 678), "📢 房间事件与掉落: " + current_event_popup, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1.0, 0.88, 0.35))
	draw_string(font, Vector2(18, 704), "键位：[WASD]移动 | [空格]翻滚擦弹(+10⚡) | [左键]主枪(尾弹顿帧击退) | [右键]瞬发重火器(带射手后坐滑步!) | [R]抓黄区换弹(+8⚡&专属Buff) | [E]升盾桩/偷电箱/进门 | [F]门前押注25⚡ | [Z/X/1-3]切枪与核心", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.82, 0.88, 0.96))
