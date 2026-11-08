# Story 001: ThemeSkinCatalog Decoupling, 3-Phase DLC/MOD Registry & Atomic Saves

> **Epic**: Save/Load, Ship Hub & Meta-Progression
> **Status**: Done
> **Layer**: Polish
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: 2026-11-08
> **Last Updated**: 2026-11-08

## Context

**GDD**: `design/gdd/meta-progression-and-save.md`
**Requirement**: `TR-meta-progression-and-save-001`

**ADR Governing Implementation**: ADR-005, ADR-006
**ADR Decision Summary**: Decouples world-lore display strings via `ThemeSkinCatalog`, isolates `"base:*"`/`"dlc:*"`/`"mod:*"` content packs in `ContentRegistry`, computes `🔥 Overdrive Sparks` settlements, and verifies `.sav` SHA-256 envelopes with automatic `.bak` fallback.
**ADR Version**: 2026-11-08

**Engine**: Godot 4.7.2 | **Risk**: LOW
**Engine Notes**: None

**Control Manifest Rules (this layer)**:
- Required: Store only immutable functional IDs in code/saves; verify SHA-256 checksum on `.sav` load and fall back to `.bak` on corruption.
- Forbidden: Selling repeatable flat "+% Damage / +HP" meta-stat grinds.
- Guardrail: Support zero-code world re-theming via `apply_skin_override_table()`.

---

## Acceptance Criteria

*From GDD `design/gdd/meta-progression-and-save.md`, scoped to this story:*

- [x] **GIVEN** `SaveAndSkinCatalog`, **WHEN** `apply_skin_override_table()` replaces currency and NPC names, **THEN** `get_skin_text()` returns the new world-theme strings with zero code or save changes.
- [x] **GIVEN** a base item `"base:peacemaker"` and a player MOD item `"mod_laser_cat:peacemaker"`, **WHEN** registered via `register_content_entry()`, **THEN** both coexist under isolated namespace keys without collision.
- [x] **GIVEN** a corrupted primary save envelope and a valid `.bak` backup envelope, **WHEN** `unpack_and_verify_save_envelope()` runs, **THEN** it detects the SHA-256 mismatch and automatically restores the `.bak` data (`restored_from_backup == true`).

---

## Implementation Notes

Implemented in `src/persistence/save_and_skin_catalog.gd` (`98 lines`).

---

## Out of Scope

- None.

---

## Files

- `src/persistence/save_and_skin_catalog.gd`
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

- Depends on: `production/epics/pit-stop-and-rival-system/story-001-pit-stop-and-rivals.md`
- Unlocks: None
