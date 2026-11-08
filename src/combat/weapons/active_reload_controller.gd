extends RefCounted
class_name ActiveReloadController
## Overhead Active Reload Slider & Weapon-Specific Signature Buff Controller (GDD #4 & ADR-003).
## Pure RefCounted class (~95 lines): delegates weapon-specific reload profile & buff to gun_<id>.gd.

const JAM_SPEED_PENALTY: float = 0.32
const SIGNATURE_BUFF_BASE_DURATION: float = 2.5

var ammo: int = 6
var is_reloading: bool = false
var reload_progress: float = 0.0
var reload_attempted: bool = false
var reload_jammed: bool = false
var signature_buff_timer: float = 0.0

var passive_sweet_spot_bonus: float = 0.0
var forge_reload_speed_mult: float = 1.0
var forge_buff_duration_bonus: float = 0.0


func equip_weapon_profile(weapon_module: RefCounted) -> void:
	var profile: Dictionary = weapon_module.call("get_profile")
	ammo = int(profile.get("mag_size", 6))
	is_reloading = false
	reload_progress = 0.0
	reload_attempted = false
	reload_jammed = false


func get_effective_sweet_window(weapon_module: RefCounted) -> Vector2:
	var profile: Dictionary = weapon_module.call("get_profile")
	var s_start: float = float(profile.get("sweet_start", 0.42))
	var s_end: float = minf(0.92, float(profile.get("sweet_end", 0.62)) + passive_sweet_spot_bonus)
	return Vector2(s_start, s_end)


func start_reload(weapon_module: RefCounted) -> bool:
	var profile: Dictionary = weapon_module.call("get_profile")
	if is_reloading or ammo >= int(profile.get("mag_size", 6)):
		return false
	is_reloading = true
	reload_progress = 0.0
	reload_attempted = false
	reload_jammed = false
	return true


## Advances slider per GDD #4 Formula 2.
func update_reload(delta: float, weapon_module: RefCounted) -> Dictionary:
	if signature_buff_timer > 0.0:
		signature_buff_timer = maxf(0.0, signature_buff_timer - delta)

	if not is_reloading:
		return {"finished": false}

	var profile: Dictionary = weapon_module.call("get_profile")
	var r_time: float = maxf(0.25, float(profile.get("reload_time", 1.15)) / maxf(0.5, forge_reload_speed_mult))
	var jam_mult: float = (1.0 - JAM_SPEED_PENALTY) if reload_jammed else 1.0
	reload_progress += (delta / r_time) * jam_mult
	if reload_progress >= 1.0:
		is_reloading = false
		reload_progress = 0.0
		ammo = int(profile.get("mag_size", 6))
		return {"finished": true, "outcome": &"NORMAL_OR_JAM_COMPLETE"}
	return {"finished": false}


## Evaluates [R] key press during active reload: returns PERFECT_RELOAD or JAMMED_RELOAD.
func attempt_active_reload(weapon_module: RefCounted) -> Dictionary:
	if not is_reloading:
		var started: bool = start_reload(weapon_module)
		return {"outcome": &"RELOAD_STARTED" if started else &"IGNORED"}

	if reload_attempted:
		return {"outcome": &"ALREADY_ATTEMPTED"}

	reload_attempted = true
	var win: Vector2 = get_effective_sweet_window(weapon_module)
	var profile: Dictionary = weapon_module.call("get_profile")
	if reload_progress >= win.x and reload_progress <= win.y:
		is_reloading = false
		reload_progress = 0.0
		ammo = int(profile.get("mag_size", 6))
		signature_buff_timer = SIGNATURE_BUFF_BASE_DURATION + forge_buff_duration_bonus
		var buff_payload: Dictionary = weapon_module.call("on_perfect_reload_activated")
		return {
			"outcome": &"PERFECT_RELOAD",
			"signature_buff": buff_payload,
			"buff_duration": signature_buff_timer
		}
	else:
		reload_jammed = true
		return {"outcome": &"JAMMED_RELOAD"}
