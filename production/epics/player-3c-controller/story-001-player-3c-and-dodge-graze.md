# Story 001: Sacrosanct 3C Movement & Committed Space Dodge-Graze Logic Core

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

**ADR Governing Implementation**: ADR-002, ADR-003
**ADR Decision Summary**: Pure `RefCounted` 3C logic core running on unblocked `delta`, enforcing `290.0–333.5 px/s` speed bounds, `0.42s` committed dodge roll (`0.28s` I-frame + `0.14s` recovery), and `42.0 px` Graze Ring (`+10.0⚡`, max `2` base or `3` with Forge Exoskeleton).
**ADR Version**: 2026-11-08

**Engine**: Godot 4.7.2 | **Risk**: LOW
**Engine Notes**: None

**Control Manifest Rules (this layer)**:
- Required: Read constants from `BalanceConfig`; keep script `<= 200 lines`; never freeze player `delta` during hitstop.
- Forbidden: Altering `DODGE_DURATION` (`0.42s`) or reducing move speed below `290.0 px/s`.
- Guardrail: Cap walk speed at `333.5 px/s` (`+15%`) and Graze payouts at `MAX_GRAZE_PER_ROLL` (`2` base, `3` max).

---

## Acceptance Criteria

*From GDD `design/gdd/player-3c-controller.md`, scoped to this story:*

- [ ] **GIVEN** normal skirmishing with any combination of passives/debuffs, **WHEN** `current_move_speed` is computed, **THEN** it equals `290.0 px/s` at base, never drops below `290.0 px/s`, and never exceeds `333.5 px/s`.
- [ ] **GIVEN** the player presses `Space` to roll through 4 enemy bullets, **WHEN** `0.00s <= dodge_timer <= 0.28s`, **THEN** the player is invulnerable, the first `2` bullets award `+10.0⚡` each (`+20.0⚡` total), and bullets #3–#4 award `0.0⚡`.
- [ ] **GIVEN** `0.28s < dodge_timer < 0.42s` (`DODGE_RECOVERY`), **WHEN** an enemy bullet hits the `14.0 px` hurtbox, **THEN** the player is vulnerable and takes hit resolution.

---

## Implementation Notes

*Derived from ADR-002 & ADR-003 Implementation Guidelines:*

Implement `Player3CLogic` (`extends RefCounted` in `src/combat/player_3c/player_3c_logic.gd`, `<= 160 lines`) handling velocity, dodge state machine, Graze Ring evaluation, and safe recoil slide clamping.

---

## Out of Scope

- Story 002: Proximity `[E]` and Ranged-Hit Tactical Arena Interactables.

---

## Files

- `src/combat/player_3c/player_3c_logic.gd`
- `tests/unit/player-3c-controller/player_3c_and_graze_test.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic
**Required evidence**:
- Logic: `tests/unit/player-3c-controller/player_3c_and_graze_test.gd` — must exist and pass

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/combat-event-bus/story-001-event-bus-and-trace.md`
- Unlocks: `production/epics/player-3c-controller/story-002-tactical-arena-interactables.md`
