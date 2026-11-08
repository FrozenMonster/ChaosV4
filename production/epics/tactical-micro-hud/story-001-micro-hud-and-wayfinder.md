# Story 001: 64px Micro-HUD Positioning, Edge Wayfinder Projection & Popup Scaling

> **Epic**: Tactical Micro-HUD & Screen UI System
> **Status**: Done
> **Layer**: Presentation
> **Type**: Logic
> **Estimate**: S
> **Manifest Version**: 2026-11-08
> **Last Updated**: 2026-11-08

## Context

**GDD**: `design/gdd/tactical-micro-hud.md`
**Requirement**: `TR-tactical-micro-hud-001`

**ADR Governing Implementation**: ADR-006
**ADR Decision Summary**: Separates pure `RefCounted` HUD coordinate/wayfinder math (`MicroHUDAndWayfinderLogic`) from thin `Z = 50` presentation rendering.
**ADR Version**: 2026-11-08

**Engine**: Godot 4.7.2 | **Risk**: LOW
**Engine Notes**: None

**Control Manifest Rules (this layer)**:
- Required: Keep UI scripts read-only with respect to gameplay state; keep file `<= 200 lines`.
- Forbidden: Mutating HP or Overcharge inside HUD rendering scripts.
- Guardrail: Clamp off-screen wayfinders strictly to `Rect2(36, 80, 1208, 560)`.

---

## Acceptance Criteria

*From GDD `design/gdd/tactical-micro-hud.md`, scoped to this story:*

- [x] **GIVEN** an off-screen door or Signal Beacon at `(1800, 360)` with camera at `(640, 360)`, **WHEN** `compute_wayfinder_screen_pos()` runs, **THEN** it clamps to `(1244, 360)` along the right safe margin.
- [x] **GIVEN** `player_pos.y = 100.0` (`< 135.0` top border), **WHEN** `get_reload_bar_offset()` runs, **THEN** the Active Reload bar flips below the player (`Y: +28.0 px`).

---

## Implementation Notes

Implemented in `src/ui/micro_hud_and_wayfinder_logic.gd` (`42 lines`).

---

## Out of Scope

- Audio ducking (handled by Epic 10).

---

## Files

- `src/ui/micro_hud_and_wayfinder_logic.gd`
- `tests/unit/test_epics_9_to_11.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic
**Required evidence**:
- Logic: `tests/unit/test_epics_9_to_11.gd` — exists and passes (`4/4 Passed`)

**Status**: [x] Verified in `tests/unit/test_epics_9_to_11.gd`

---

## Dependencies

- Depends on: `production/epics/dual-gun-overcharge-engine/story-002-weapon-reload-profiles-and-buffs.md`
- Unlocks: None
