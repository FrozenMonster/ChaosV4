# Story 002: Customizable Proximity [E] & Ranged-Hit Tactical Arena Interactables

> **Epic**: Player 3C, Dodge-Graze & Tactical Arena Interactables
> **Status**: Ready
> **Layer**: Foundation
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: 2026-11-08
> **Last Updated**: 2026-11-08

## Context

**GDD**: `design/gdd/player-3c-controller.md`
**Requirement**: `TR-player-3c-controller-001`

**ADR Governing Implementation**: ADR-003
**ADR Decision Summary**: Data-driven `ArenaInteractableData` supporting `PROXIMITY_KEY_E` (`DEPLOY_SHIELD_COVER`, `OVERCHARGE_CAPACITOR`, `KINETIC_LAUNCHPAD`) and `RANGED_HIT` (`EXPLOSIVE_BLAST`, `CRYO_SLOW_FIELD`, `PRISM_BULLET_SPLIT`).
**ADR Version**: 2026-11-08

**Engine**: Godot 4.7.2 | **Risk**: LOW
**Engine Notes**: None

**Control Manifest Rules (this layer)**:
- Required: Single-file locality (`<= 200 lines`), pure `RefCounted` state resolution, emit `interactable_triggered` via `CombatEventBus`.
- Forbidden: Hardcoding derivative single-purpose table-flip logic.
- Guardrail: Ground cryo/blast zones capped at `Alpha <= 0.45` (`Z = 10`).

---

## Acceptance Criteria

*From GDD `design/gdd/player-3c-controller.md`, scoped to this story:*

- [ ] **GIVEN** a `PROXIMITY_KEY_E` interactable (`DEPLOY_SHIELD_COVER` or `OVERCHARGE_CAPACITOR`), **WHEN** the player presses `[E]` within `40.0 px`, **THEN** it deploys the `60.0 HP` barrier (clearing bullets within `28.0 px`) or grants `+22.0⚡` Overcharge + stun pulse.
- [ ] **GIVEN** a `RANGED_HIT` interactable (`EXPLOSIVE_BLAST`, `CRYO_SLOW_FIELD`, or `PRISM_BULLET_SPLIT`), **WHEN** struck by a player projectile, **THEN** it triggers the configured `65.0 DMG` blast, `3.5s` `50%` cryo slow zone, or `5`-bolt homing prism split.

---

## Implementation Notes

*Derived from ADR-003 Implementation Guidelines:*

Implement `src/combat/player_3c/arena_interactable_logic.gd` (`<= 150 lines`) evaluating proximity `[E]` priority and ranged hit triggers from `ArenaInteractableData`.

---

## Out of Scope

- Story 001: Base player movement and dodge roll.

---

## Files

- `src/combat/player_3c/arena_interactable_logic.gd`
- `tests/unit/player-3c-controller/arena_interactables_test.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic
**Required evidence**:
- Logic: `tests/unit/player-3c-controller/arena_interactables_test.gd` — must exist and pass

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/player-3c-controller/story-001-player-3c-and-dodge-graze.md`
- Unlocks: `production/epics/bullet-hell-damage-system/story-001-bullet-pool-and-coalescing.md`
