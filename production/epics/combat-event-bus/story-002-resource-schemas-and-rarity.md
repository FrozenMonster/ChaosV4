# Story 002: 7-Slot Equipment, 4-Tier Rarity & ArenaInteractable Resource Schemas

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

**ADR Governing Implementation**: ADR-001, ADR-006
**ADR Decision Summary**: Defines typed `Resource` / data schemas with `"base:id"` namespace prefixes, `rarity_tier` (`COMMON / RARE / EPIC / LEGENDARY`), and safe fallback clamping on invalid fields.
**ADR Version**: 2026-11-08

**Engine**: Godot 4.7.2 | **Risk**: LOW
**Engine Notes**: None

**Control Manifest Rules (this layer)**:
- Required: Single-file locality (`<= 200 lines`), `"base:<id>"` namespace validation, safe clamping for `sweet_spot_start/end` and `overcharge_cost`.
- Forbidden: Crashing on out-of-range resource fields.
- Guardrail: Clamp invalid `sweet_spot` to `[0.42, 0.62]` and `overcharge_cost <= 0` to `45.0`.

---

## Acceptance Criteria

*From GDD `design/gdd/combat-event-bus.md`, scoped to this story:*

- [ ] **GIVEN** a `PrimaryWeaponData` or `HeavyWeaponData` with invalid `sweet_spot_start = 0.80, sweet_spot_end = 0.50` or `overcharge_cost = -10.0`, **WHEN** validated, **THEN** it clamps to safe defaults (`0.42–0.62`, `45.0⚡`) without crashing.
- [ ] **GIVEN** any 7-Slot schema or `ArenaInteractableData`, **WHEN** initialized with `rarity_tier`, **THEN** it automatically resolves its base shop price (`55/85/130/190 🪙`) and salvage payout (`15/25/40/65 🪙`).

---

## Implementation Notes

*Derived from ADR-001 & ADR-006 Implementation Guidelines:*

Implement `src/core/schemas/equipment_schemas.gd` (`<= 150 lines`) providing validated data builders for `PrimaryWeaponData`, `HeavyWeaponData`, `DynamoCoreData`, `ActiveItemData`, `PassiveRelicData`, and `ArenaInteractableData`.

---

## Out of Scope

- Story 001: Event Bus signal dispatching.

---

## Files

- `src/core/schemas/equipment_schemas.gd`
- `tests/unit/combat-event-bus/resource_schemas_test.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic
**Required evidence**:
- Logic: `tests/unit/combat-event-bus/resource_schemas_test.gd` — must exist and pass

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/combat-event-bus/story-001-event-bus-and-trace.md`
- Unlocks: `production/epics/player-3c-controller/story-001-player-3c-and-dodge-graze.md`
