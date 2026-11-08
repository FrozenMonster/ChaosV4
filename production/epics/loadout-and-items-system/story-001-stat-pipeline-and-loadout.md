# Story 001: 4-Stage Commutative StatPipeline, 7-Slot Loadout & Composable Relics

> **Epic**: 7-Slot Loadout & Tactical Items System
> **Status**: Done
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: 2026-11-08
> **Last Updated**: 2026-11-08

## Context

**GDD**: `design/gdd/loadout-and-items-system.md`
**Requirement**: `TR-loadout-and-items-system-001`

**ADR Governing Implementation**: ADR-001, ADR-003
**ADR Decision Summary**: Implements the 4-Stage Commutative StatPipeline (`Flat -> Pct_Add -> Indep_Mult -> Safety_Clamp`) with `NaN` fault isolation, 7-Slot Loadout management, `exclusivity_group` mutex filtering, and `[7]/[8]/[9]/[G]` salvage into `🪙 Bounty Chips`.
**ADR Version**: 2026-11-08

**Engine**: Godot 4.7.2 | **Risk**: LOW
**Engine Notes**: None

**Control Manifest Rules (this layer)**:
- Required: Single-file locality (`<= 200 lines`), pure `RefCounted` logic core, Stage 4 safety clamps (`0.42s` locked dodge duration, `<= 333.5 px/s` speed).
- Forbidden: Order-dependent stat multiplication or unguarded `NaN` propagation.
- Guardrail: Cap Passive Relics strictly at `3` slots.

---

## Acceptance Criteria

*From GDD `design/gdd/loadout-and-items-system.md`, scoped to this story:*

- [x] **GIVEN** 3 Passive Relics equipped in `[A, B, C]` vs. `[C, A, B]` order (including a faulty `NaN` modifier), **WHEN** `StatPipeline.evaluate_stat()` runs, **THEN** both orders return the exact same clamped float and ignore `NaN`.
- [x] **GIVEN** an equipped Relic with `exclusivity_group = &"max_overcharge_rule"`, **WHEN** `filter_eligible_relic_pool()` filters candidate drops, **THEN** conflicting items in the same group are excluded.
- [x] **GIVEN** `slot_passives` is full (`3/3`) with `bounty_audit_magnet` active, **WHEN** a 4th Relic is swapped into a `RARE` slot (`25 🪙` base), **THEN** the evicted Relic salvages into `38 🪙` (`+50%`).

---

## Implementation Notes

Implemented in `src/core/stat_pipeline.gd` (`65 lines`) and `src/features/loadout/loadout_and_relic_logic.gd` (`112 lines`).

---

## Out of Scope

- Visual HUD rendering (handled by Epic 9 `tactical-micro-hud`).

---

## Files

- `src/core/stat_pipeline.gd`
- `src/features/loadout/loadout_and_relic_logic.gd`
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

- Depends on: `production/epics/combat-event-bus/story-001-event-bus-and-trace.md`
- Unlocks: `production/epics/pit-stop-and-rival-system/story-001-pit-stop-and-rivals.md`
