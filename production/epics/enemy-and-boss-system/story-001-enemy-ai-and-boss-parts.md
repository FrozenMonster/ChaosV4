# Story 001: 3-Tier AI, Elite Plugins, BossPartNode Breaks & Entity UID Registry

> **Epic**: Enemy AI, Elite/Boss Interrupts & Boss System
> **Status**: Done
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: 2026-11-08
> **Last Updated**: 2026-11-08

## Context

**GDD**: `design/gdd/enemy-and-boss-system.md`
**Requirement**: `TR-enemy-and-boss-system-001`

**ADR Governing Implementation**: ADR-004
**ADR Decision Summary**: Implements monotonic 64-bit integer `entity_uid` handles (`EnemyAndBossLogic`), zero interrupt UI on Tier 1 Fodder, Elite/Boss-exclusive `0.85s` Weak-Point Interrupts (`+22.0⚡`), destructible `BossPartNode` sub-hitboxes, and the `18%/s` Boss DPS Soft-Cap.
**ADR Version**: 2026-11-08

**Engine**: Godot 4.7.2 | **Risk**: LOW
**Engine Notes**: None

**Control Manifest Rules (this layer)**:
- Required: Store integer `entity_uid` handles instead of raw `Node` references; restrict Weak-Point Interrupts to Tier 2 (Elites) and Tier 3 (Bosses).
- Forbidden: Emitting interrupt reticles on Tier 1 Fodder mobs.
- Guardrail: Attenuate non-interrupt Boss DPS exceeding `18% Max HP / sec` to `35%`.

---

## Acceptance Criteria

*From GDD `design/gdd/enemy-and-boss-system.md`, scoped to this story:*

- [x] **GIVEN** a Tier 1 Fodder mob (`tier = 1`), **WHEN** `start_weakpoint_windup()` is called, **THEN** it returns `false` and never triggers an interrupt window.
- [x] **GIVEN** a Boss with a destructible `BossPartNode` (`left_missile_pod`), **WHEN** damage reduces the part's HP to `0.0`, **THEN** `part_broken` equals `&"left_missile_pod"`, its attack ID is disabled, and `+22.0⚡` Overcharge is awarded.
- [x] **GIVEN** an enemy killed mid-frame, **WHEN** a homing missile queries `get_alive(entity_uid)`, **THEN** it safely returns `{}` with zero null-reference crash.

---

## Implementation Notes

Implemented in `src/combat/enemies/enemy_and_boss_logic.gd` (`128 lines`).

---

## Out of Scope

- Room wave budgets (handled by Epic 7 `door-routing-and-floor-gen`).

---

## Files

- `src/combat/enemies/enemy_and_boss_logic.gd`
- `tests/unit/test_epics_5_to_8.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic
**Required evidence**:
- Logic: `tests/unit/test_epics_5_to_8.gd` — exists and passes (`5/5 Passed`)

**Status**: [x] Verified in `tests/unit/test_epics_5_to_8.gd`

---

## Dependencies

- Depends on: `production/epics/bullet-hell-damage-system/story-001-bullet-pool-and-coalescing.md`
- Unlocks: `production/epics/door-routing-and-floor-gen/story-001-floor-router-and-objectives.md`
