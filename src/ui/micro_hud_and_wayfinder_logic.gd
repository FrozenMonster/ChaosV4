extends RefCounted
class_name MicroHUDAndWayfinderLogic
## 64px Micro-HUD Positioning, Off-Screen Edge Wayfinder Projection & Popup Scaling (GDD #8 & ADR-006).
## Pure RefCounted core (~85 lines): zero-scene mathematical verification of all HUD coordinates.

const SCREEN_CENTER := Vector2(640.0, 360.0)
const SAFE_HALF_W: float = 604.0 # 640 - 36px margin inset
const SAFE_HALF_H: float = 280.0 # Inset above/below top & bottom perimeter HUD bars
const CRIT_INITIAL_BOOST: float = 0.45
const CRIT_SNAP_TIME: float = 0.16


## Computes overhead Active Reload bar Y-offset: flips below player (+28px) if player is near top wall (<135px) (GDD #8 Edge Case).
static func get_reload_bar_offset(player_pos: Vector2) -> Vector2:
	var y_ofs: float = 28.0 if player_pos.y < 135.0 else -38.0
	return Vector2(-38.0, y_ofs)


## Computes GDD #8 Formula 1 (Off-Screen Wayfinder Margin Projection onto Rect2(36, 80, 1208, 560)).
static func compute_wayfinder_screen_pos(target_world_pos: Vector2, camera_center_world: Vector2 = SCREEN_CENTER) -> Vector2:
	var delta_vec: Vector2 = target_world_pos - camera_center_world
	if absf(delta_vec.x) <= SAFE_HALF_W and absf(delta_vec.y) <= SAFE_HALF_H:
		return SCREEN_CENTER + delta_vec # Target is already inside the safe camera viewport

	var dir_vec: Vector2 = delta_vec.normalized()
	var tx: float = SAFE_HALF_W / maxf(0.0001, absf(dir_vec.x))
	var ty: float = SAFE_HALF_H / maxf(0.0001, absf(dir_vec.y))
	var t_edge: float = minf(tx, ty)
	return SCREEN_CENTER + dir_vec * t_edge


## Computes GDD #8 Formula 2 (Tiered Floating Combat Text Scale & Decay).
static func compute_popup_render_scale(is_crit_or_interrupt: bool, t_elapsed: float) -> float:
	if not is_crit_or_interrupt:
		return 1.0
	var decay: float = maxf(0.0, 1.0 - (t_elapsed / CRIT_SNAP_TIME))
	return 1.0 + CRIT_INITIAL_BOOST * decay
