# ADR-006: Pure `RefCounted` Testability, Skin Decoupling & 3-Phase DLC/MOD Loader

## Status

Accepted

## Date

2026-11-08

## Last Verified

2026-11-08

## Decision Makers

user, technical-director, lead-programmer, qa-lead

## Summary

Separates all gameplay math and state into **pure `RefCounted` classes** (enabling `<0.5s` zero-scene headless unit tests and 1,000-room balance simulations), routes all world-lore strings and art paths through `ThemeSkinCatalog` for instant pre-production re-theming, and establishes a **3-Phase Progressive `ContentRegistry` (`"base:id"` $\rightarrow$ `"dlc:id"` $\rightarrow$ `"mod:id"`)** so MVP iteration is instant while 1.0/DLC/MOD scaling requires zero core rewrites.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 |
| **Domain** | Core |
| **Layer** | Foundation |
| **Knowledge Risk** | LOW |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md` |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | Headless GdUnit4 test suite executing in `< 1.0s` with zero `.tscn` scene dependencies |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-001, ADR-003, ADR-005 |
| **Enables** | None |
| **Blocks** | Epic 6 (Tactical Micro-HUD, Audio Juice, Hub & Save System) |
| **Ordering Note** | Connects Foundation math cores to Presentation views and Persistence |

## Context

Three strategic requirements must work together without slowing down MVP development:
1. **High Testability at Near-Zero Cost**: QA and developers must be able to test any weapon, relic, Overcharge formula, or 1,000-room economy balance in `< 0.5s` without building complex `.tscn` mock scenes.
2. **Instant World-Theme / Lore Re-Skinning**: The user may refine or overhaul the world setting, character names, and item flavor text prior to Stage 4 formal art production.
3. **Future DLC & Steam Workshop MOD Support**: The architecture must scale to post-launch DLC packs and player-authored MODs without rewriting core systems.

## Decision

1. **Pure `RefCounted` Domain Logic Core (零场景极速单测架构)**:
   - Core state and math classes (`OverchargeLedger`, `ActiveReloadController`, `AegisShieldState`, `StatPipeline`, `RarityRoller`, `DeterministicRNGService`) extend `RefCounted` and accept plain data arguments (`delta: float`, `config: Dictionary/Resource`).
   - Automated GdUnit4 tests instantiate these classes directly in memory (`var ledger := OverchargeLedger.new()`) and run 100+ assertions or 1,000 simulated rooms in `< 0.5 seconds` via `godot --headless`.
2. **Readable Semantic IDs + `ThemeSkinCatalog` Indirection (零负担换皮架构)**:
   - Every item, weapon, NPC, and currency uses a readable mechanic-based ID with a pack namespace prefix: `"base:gun_peacemaker"`, `"base:npc_blackmarket_dealer"`, `"base:currency_bounty_chips"`.
   - During MVP, UI reads default Chinese display strings directly through `ThemeSkinCatalog.get_text(id, fallback_zh)`. When re-theming the world or localizing, updating `ThemeSkinCatalog`'s lookup table re-skins the entire game and existing `.sav` files with zero code edits.
3. **3-Phase Progressive Content & MOD Loader (`ContentRegistry`)**:
   - **Phase 1 (MVP / Demo)**: `ContentRegistry` loads `"base:*"` definitions directly from `res://src/content/`. Zero external loader overhead.
   - **Phase 2 (1.0 Release)**: Adds background threaded pre-fetching per stratum (`ResourceLoader.load_threaded_request`).
   - **Phase 3 (DLC & Workshop MODs)**: On boot, `ContentRegistry` mounts any `res://dlc/*.pck` and scans `user://mods/<mod_id>/manifest.json`, registering `"dlc_01:*"` and `"mod_id:*"` weapons/relics/rooms into the drop pools under the same fault-isolated `StatPipeline` and `CombatEventBus` guards.

## Alternatives Considered

- **Coupling Logic Directly Inside `CharacterBody2D` / `Node2D` Scripts**: Rejected because testing a single reload formula would require booting a full 2D physics scene, multiplying test authoring and execution costs by `20x`.
- **Building a Heavyweight External MOD Sandbox VM in MVP**: Rejected as premature over-engineering; reserving `"namespace:id"` strings and `ContentRegistry` lookup in MVP costs `< 20 lines` of code while keeping the door 100% open for Phase 3.

## Consequences

- **Positive**: Sub-second zero-scene unit tests and automated balance simulations; instant world-lore re-skinning; zero-tax MVP speed with native DLC/MOD readiness.
- **Negative**: Thin `Node2D` views delegate state mutations to their `RefCounted` logic instance (`player_logic.update(delta)`), which also naturally keeps every file well under the `200-line` locality cap.

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| `meta-progression-and-save.md` | `ThemeSkinCatalog` mechanics-to-lore skin decoupling, `meta_profile.sav` + `.bak`, `active_run_checkpoint.sav` | Implemented in `ThemeSkinCatalog`, `ContentRegistry`, and `SaveManager` |
| `tactical-micro-hud.md` | Thin `Z = 50` presentation layer reading state without mutating combat math | Enforced by separating `RefCounted` logic cores from `Node2D` HUD views |
| `combat-audio-juice-system.md` | 4-Bus Sidechain Ducking (`-4.0 dB`) and `streak_pitch_scale` ladders | Driven by Stage 400 Event Bus signals on a thin presentation controller |
