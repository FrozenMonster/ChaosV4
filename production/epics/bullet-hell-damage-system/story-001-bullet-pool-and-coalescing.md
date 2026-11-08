# Story 001: 800-Slot Zero-Alloc BulletPool, Synergy Coalescing & Non-Blocking Hitstop

> **Epic**: Pooled Bullet-Hell & Damage System
> **Status**: Ready
> **Layer**: Core
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: 2026-11-08
> **Last Updated**: 2026-11-08

## Context

**GDD**: `design/gdd/bullet-hell-damage-system.md`
**Requirement**: `TR-bullet-hell-damage-system-001`

**ADR Governing Implementation**: ADR-002, ADR-004
**ADR Decision Summary**: Pre-allocates 800 projectile slots with zero runtime `instantiate()`, coalesces player bursts `> 24` into damage multipliers (`MAX_PLAYER_BURST_CAP = 24`), and enforces One-Way Non-Blocking Hitstop (`world_delta = delta * 0.18`, player `delta` unblocked).
**ADR Version**: 2026-11-08

**Engine**: Godot 4.7.2 | **Risk**: LOW
**Engine Notes**: None

**Control Manifest Rules (this layer)**:
- Required: Pre-allocate 800 slots; coalesce bursts `> 24`; use integer `entity_uid` handles.
- Forbidden: Calling `instantiate()`/`queue_free()` in combat or blocking player `delta` during hitstop.
- Guardrail: `MAX_PLAYER_BURST_CAP = 24`.

---

## Acceptance Criteria

*From GDD `design/gdd/bullet-hell-damage-system.md` & ADR-002, scoped to this story:*

- [ ] **GIVEN** 500 enemy bullets and 200 player bullets active in `BulletPoolLogic`, **WHEN** updated over 300 frames, **THEN** `0` node allocations occur and recycling overwrites dormant slots cleanly.
- [ ] **GIVEN** a single player firing burst + prism/relic chain requests `N = 48` projectiles (`> MAX_PLAYER_BURST_CAP = 24`) at `10.0 DMG` each, **WHEN** spawned via `spawn_player_burst()`, **THEN** exactly `24` projectiles spawn with `20.0 DMG` each (`2.0x` coalesced multiplier, `0` DPS lost).
- [ ] **GIVEN** `hitstop_timer = 0.045s` is active, **WHEN** frame delta is resolved, **THEN** `get_player_delta(delta)` returns `1.0 * delta` while `get_world_delta(delta)` returns `0.18 * delta`.

---

## Implementation Notes

*Derived from ADR-002 Implementation Guidelines:*

Implement `BulletPoolLogic` (`extends RefCounted` in `src/combat/bullet_pool/bullet_pool_logic.gd`, `<= 180 lines`) managing the 800-slot array, bullet-clear shockwave queries, burst coalescing, and non-blocking hitstop time dilation.

---

## Out of Scope

- Story 002: 3-Tier Recoil/Knockback and 3-Pip Overcharge Aegis Shield resolution.

---

## Files

- `src/combat/bullet_pool/bullet_pool_logic.gd`
- `tests/unit/bullet-hell-damage-system/bullet_pool_and_coalescing_test.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic
**Required evidence**:
- Logic: `tests/unit/bullet-hell-damage-system/bullet_pool_and_coalescing_test.gd` — must exist and pass

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/combat-event-bus/story-001-event-bus-and-trace.md`
- Unlocks: `production/epics/bullet-hell-damage-system/story-002-recoil-and-aegis-shield.md`
