# Story 001: 4-Stage Priority Event Bus, Recursion Guard & F3 Trace Ring Buffer

> **Epic**: Combat Event Bus & Data Schema
> **Status**: Ready
> **Layer**: Foundation
> **Type**: Logic
> **Estimate**: S
> **Manifest Version**: 2026-11-08
> **Last Updated**: 2026-11-08

## Context

**GDD**: `design/gdd/combat-event-bus.md`
**Requirement**: `TR-combat-event-bus-001`
*(Requirement text lives in `docs/architecture/tr-registry.yaml` — read fresh at review time)*

**ADR Governing Implementation**: ADR-001: Combat Event Bus, F3 Trace Buffer & Per-Frame Recursion Guard
**ADR Decision Summary**: Implements a 4-stage priority dispatcher (`100 -> 200 -> 300 -> 400`) with `MAX_RECURSION_DEPTH = 2`, `MAX_PROCS_PER_FRAME = 32`, and an `F3` 64-entry trace ring buffer.
**ADR Version**: 2026-11-08

**Engine**: Godot 4.7.2 | **Risk**: LOW
**Engine Notes**: None

**Control Manifest Rules (this layer)**:
- Required: Keep file `<= 200 lines`, pure `RefCounted` testable core, 100% static typing.
- Forbidden: Unbounded recursion or direct cross-system node path calls.
- Guardrail: `MAX_RECURSION_DEPTH = 2` and `MAX_PROCS_PER_FRAME = 32`.

---

## Acceptance Criteria

*From GDD `design/gdd/combat-event-bus.md`, scoped to this story:*

- [ ] **GIVEN** listeners registered at Priorities `400`, `200`, `300`, `100`, **WHEN** a signal is emitted, **THEN** listeners execute strictly in `100 -> 200 -> 300 -> 400` order over a snapshot copy.
- [ ] **GIVEN** two listeners that recursively emit each other, **WHEN** triggered at `recursion_depth = 0`, **THEN** secondary procs stop at `current_recursion_depth == 2` (`effective_proc_allowance == 0`) with zero infinite loop.
- [ ] **GIVEN** `MAX_PROCS_PER_FRAME = 32`, **WHEN** 60 secondary procs are requested in one frame, **THEN** exactly 32 execute and all emissions are recorded in the 64-entry `F3` trace ring buffer.

---

## Implementation Notes

*Derived from ADR-001 Implementation Guidelines:*

Implement `CombatEventBus` (`<= 160 lines`) as a pure `RefCounted` core (wrapped by an optional Autoload node) with `subscribe(signal_name, callable, priority)`, `emit_combat_event(signal_name, payload, is_secondary_proc)`, `begin_frame()`, and `get_trace_log() -> Array[Dictionary]`.

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 002: 7-Slot Equipment & `ArenaInteractableData` Resource schemas.

---

## Files

- `src/core/combat_event_bus.gd`
- `tests/unit/combat-event-bus/event_bus_and_trace_test.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic
**Required evidence**:
- Logic: `tests/unit/combat-event-bus/event_bus_and_trace_test.gd` — must exist and pass

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: None
- Unlocks: `production/epics/combat-event-bus/story-002-resource-schemas-and-rarity.md`
