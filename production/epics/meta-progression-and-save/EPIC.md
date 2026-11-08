# Epic: Save/Load, Ship Hub & Meta-Progression

> **Layer**: Polish
> **GDD**: design/gdd/meta-progression-and-save.md
> **Architecture Module**: `src/persistence/` & `src/core/`
> **Status**: Ready
> **Stories**: Not yet created — run `/create-stories meta-progression-and-save`

## Overview

Implements the **Base Hub (`HubScene`)** with 5 interactive stations (Playable Character Roster, Quartermaster Meta-Unlocks, Firing Range Target Dummies, Armory/Lore Codex, and Overdrive Pact Difficulty Board), **Horizontal Pool-Expansion Meta-Progression** (`🔥 Overdrive Sparks`), **Atomic Save Serialization** (`meta_profile.sav` + `.bak` SHA-256 fallback & room-boundary `active_run_checkpoint.sav`), **`ThemeSkinCatalog` Mechanics-to-Lore Decoupling**, and the **3-Phase `ContentRegistry` DLC/MOD Loader**.

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|------------------|-------------|
| ADR-005: 6-Stream Coordinate-Hashed Deterministic RNG & Bad-Luck Pity System | Coordinate-hashed seeds stored in `active_run_checkpoint.sav` block `Alt+F4` save-scumming | LOW |
| ADR-006: Pure `RefCounted` Testability, Skin Decoupling & 3-Phase DLC/MOD Loader | `ThemeSkinCatalog` lore decoupling and 3-Phase `ContentRegistry` (`"base:*"`, `"dlc:*"`, `"mod:*"`) | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-meta-progression-and-save-001 | 6-Stream coordinate-hashed DeterministicRNGService, ThemeSkinCatalog lore decoupling, 3-Phase DLC/MOD ContentRegistry, and atomic meta/checkpoint saves | ADR-005, ADR-006 ✅ |

## Definition of Done

- Every story implemented, reviewed and closed with `/story-done`
- Every acceptance criterion of `design/gdd/meta-progression-and-save.md` verified
- Logic and Integration stories have passing tests in the test root
- Visual/Feel and UI stories have retained screenshots in `production/qa/evidence/`
  (a lead sign-off too for Visual/Feel)
