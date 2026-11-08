# Story 001: 5 Non-Rectangular Footprints, 4 Room Objectives & Hades-Style Exits

> **Epic**: 3-Door Routing, Overdrive Bet & Floor Generator
> **Status**: Done
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: 2026-11-08
> **Last Updated**: 2026-11-08

## Context

**GDD**: `design/gdd/door-routing-and-floor-gen.md`
**Requirement**: `TR-door-routing-and-floor-gen-001`

**ADR Governing Implementation**: ADR-005
**ADR Decision Summary**: Generates 7-Node strata using coordinate-hashed `stream_topology` across 5 footprints, 4 `RoomObjectiveType` modes (`EXTERMINATION`, `SABOTAGE_BEACONS`, `OVERDRIVE_SURVIVAL`, `CONDUIT_UPLOAD`), 1–3 distributed exits, `MAX_CONCURRENT_ENEMIES = 7` wave splitting, and `-25⚡` Overdrive Bets.
**ADR Version**: 2026-11-08

**Engine**: Godot 4.7.2 | **Risk**: LOW
**Engine Notes**: None

**Control Manifest Rules (this layer)**:
- Required: Use coordinate-hashed `DeterministicRNGService` (`stream_topology`); cap concurrent Wave 1 enemies at `7`.
- Forbidden: Using global `randf()` or spawningconsecutive identical room footprints.
- Guardrail: Trigger Rival *Vesper* ambush on Node 6 when `stratum_bet_streak >= 2`.

---

## Acceptance Criteria

*From GDD `design/gdd/door-routing-and-floor-gen.md`, scoped to this story:*

- [x] **GIVEN** consecutive nodes in a 7-Node Stratum, **WHEN** `generate_room_node()` runs, **THEN** consecutive footprints never repeat, Wave 1 enemies never exceed `7`, and 1–3 distributed exit doors are assigned.
- [x] **GIVEN** the player locks `>= 2` Overdrive Bets (`-25⚡`) in a Stratum, **WHEN** Node 6 is generated, **THEN** `rival_vesper_ambush` is `true` and reward choices upgrade to `2`.

---

## Implementation Notes

Implemented in `src/progression/floor_router/floor_router_logic.gd` (`105 lines`).

---

## Out of Scope

- Shop and Forge card generation (handled by Epic 8).

---

## Files

- `src/progression/floor_router/floor_router_logic.gd`
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

- Depends on: `production/epics/enemy-and-boss-system/story-001-enemy-ai-and-boss-parts.md`
- Unlocks: `production/epics/pit-stop-and-rival-system/story-001-pit-stop-and-rivals.md`
