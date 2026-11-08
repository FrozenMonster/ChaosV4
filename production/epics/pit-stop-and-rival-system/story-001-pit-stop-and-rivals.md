# Story 001: 4-Tier Rarity, Mystery Contraband Blind Box, 4-Axis Forge & 3-Role NPCs

> **Epic**: Pit-Stop, Bounty Chip Economy & Rival Cast System
> **Status**: Done
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: 2026-11-08
> **Last Updated**: 2026-11-08

## Context

**GDD**: `design/gdd/pit-stop-and-rival-system.md`
**Requirement**: `TR-pit-stop-and-rival-system-001`

**ADR Governing Implementation**: ADR-003, ADR-005
**ADR Decision Summary**: Implements coordinate-hashed `60 🪙` Mystery Contraband Blind Boxes (blocking `Alt+F4` save-scumming), strict `+1 ❤️` heal cap, Bucky's 4-Axis Forge (preserving locked `0.42s` dodge roll), and the 3-Category NPC / Rival-to-Playable state machine.
**ADR Version**: 2026-11-08

**Engine**: Godot 4.7.2 | **Risk**: LOW
**Engine Notes**: None

**Control Manifest Rules (this layer)**:
- Required: Cap Pit-Stop healing strictly at `+1 ❤️` per interaction; use coordinate hashing for Mystery Boxes.
- Forbidden: Altering `DODGE_DURATION` (`0.42s`) in Axis 4 Exoskeleton upgrades.
- Guardrail: Overdrive Bet rooms set `w_common = 0.0` (`0%` Common drops).

---

## Acceptance Criteria

*From GDD `design/gdd/pit-stop-and-rival-system.md`, scoped to this story:*

- [x] **GIVEN** Old Rex's `60 🪙` Mystery Contraband Box at `(stratum=1, node=4, box=0)`, **WHEN** opened before and after a simulated `Alt+F4` reload under the same `Master_Seed`, **THEN** both rolls return the exact same outcome dictionary.
- [x] **GIVEN** Bucky's emergency heal or Old Rex's ration, **WHEN** applied to a player at `3/6 HP`, **THEN** HP increases strictly to `4/6` (`+1 ❤️`).
- [x] **GIVEN** Category C Rival *Vesper*, **WHEN** she transitions through ambush defeat and Hub recruitment, **THEN** her state advances `STRANGER_RIVAL -> AMBUSH_HIDDEN_BOSS -> SHIP_ALLY -> PLAYABLE_GUNBOY`.

---

## Implementation Notes

Implemented in `src/progression/pit_stop/pit_stop_and_rival_logic.gd` (`95 lines`).

---

## Out of Scope

- Persistent save file encryption (handled by Epic 11).

---

## Files

- `src/progression/pit_stop/pit_stop_and_rival_logic.gd`
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

- Depends on: `production/epics/door-routing-and-floor-gen/story-001-floor-router-and-objectives.md`
- Unlocks: `production/epics/meta-progression-and-save/story-001-skin-catalog-and-save.md`
