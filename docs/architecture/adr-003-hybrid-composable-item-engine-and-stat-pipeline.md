# ADR-003: 80/20 Hybrid Composable Item Engine, 4-Stage Stat Pipeline & Single-File Locality

## Status

Accepted

## Date

2026-11-08

## Last Verified

2026-11-08

## Decision Makers

user, systems-designer, lead-programmer

## Summary

Combines zero-code `When -> If -> Do` composable data blocks (for 80% of items) with a self-contained `custom_behavior_script` escape hatch (for 20% rule-breaking Legendaries), evaluated through a commutative 4-Stage Stat Pipeline (`StatPipeline`) and enforcing a strict **`<= 200` lines Single-File Edit Locality** rule.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 |
| **Domain** | Core |
| **Layer** | Feature |
| **Knowledge Risk** | LOW |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md` |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | Commutative order-independence test (`[A,B,C] == [C,A,B]`) and per-item `NaN` fault-isolation test |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-001, ADR-002 |
| **Enables** | ADR-006 |
| **Blocks** | Epic 3 (Dual-Gun Overcharge Engine & 7-Slot Loadout) |
| **Ordering Note** | Builds on Event Bus (ADR-0001) and Bullet Decorators (ADR-0002) |

## Context

We need to support 100–300 weapons, Dynamo Cores, Passive Relics, and Forge upgrades across 4 Rarity Tiers (`COMMON / RARE / EPIC / LEGENDARY`) such that: (1) adding or tweaking any single weapon or item touches **only 1 self-contained file (`<= 200 lines`)**, (2) standard items can be configured in minutes without boilerplate code, (3) wild rule-bending Legendary items are not bottlenecked by a rigid table schema, and (4) combining any 3 relics + Forge mods never causes order-dependent math bugs or crashes.

## Decision

1. **80/20 Hybrid Composable Item & Weapon Architecture**:
   - **80% Standard Items (Data-Driven `When -> If -> Do` Blocks)**: Authored via `.tres` / compact data definitions pairing a `trigger_hook` (`ON_PERFECT_RELOAD`, `ON_FINAL_ROUND_FIRE`, `ON_DODGE_GRAZE`, etc.), a `condition_filter`, and reusable `atomic_actions` (`ACT_SPAWN_RING_WAVE`, `ACT_CHAIN_LIGHTNING`, `ACT_ADD_BULLET_DECORATOR`).
   - **20% Rule-Breaking Legendaries (`custom_behavior_script` Escape Hatch)**: Any `PassiveRelicData` or `PrimaryWeaponData` may attach a self-contained `<= 120 line` script implementing `on_equip()`, `on_trigger(payload)`, and `on_unequip()` in its own file (`src/content/relics/relic_<id>.gd`).
2. **Single-File Edit Locality & `balance_config.gd` Contract (`<= 200` Lines Cap)**:
   - Each weapon (`gun_<id>.gd`) encapsulates its own reload sweet-spot window (`sweet_start`, `sweet_end`), Final Round projectile logic, and `2.5s` Signature Buff inside one file. Global baseline constants live exclusively in `src/core/balance_config.gd`.
3. **4-Stage Commutative Stat Pipeline (`StatPipeline` — Pure `RefCounted`)**:
   - All stat modifications evaluate via `clamp((base + sum_flat) * max(0.1, 1.0 + sum_pct) * prod_mult, min_floor, max_ceil)`, ensuring 100% order-independence and enforcing Pillar 1 safety caps (`<= 333.5 px/s` walk speed, `0.42s` locked dodge duration).
4. **Per-Item Fault Isolation Guard**:
   - When `LoadoutManager` iterates through equipped relics, any `is_nan()` or `is_inf()` output from a custom/MOD script is clamped to `base_value` and logged once.

## Alternatives Considered

- **100% Pure Data-Table DSL for All Items**: Rejected because forcing complex Legendary mechanics into JSON/table DSLs creates unreadable config bloat.
- **Monolithic `weapon_manager.gd` / `item_manager.gd` Switch Statements**: Rejected because every minor tweak forces developers/AI agents to read and edit a 2,000-line file.

## Consequences

- **Positive**: Surgical 1-file edits for any weapon or item; zero synergy crashes; effortless scaling from 10 MVP items to 300+ release/DLC items.
- **Negative**: Requires adhering to the 1-file-per-item directory convention (`src/content/weapons/`, `src/content/relics/`).

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| `loadout-and-items-system.md` | 7-Slot Loadout Schema, `When -> If -> Do` blocks, `evaluate_stat` 4-Stage Pipeline, `exclusivity_group` mutex filter | Implemented directly in `StatPipeline` and `LoadoutManager` |
| `dual-gun-overcharge-engine.md` | Weapon-specific Active Reload sweet spots (`0.22–0.40`, `0.42–0.62`, `0.65–0.81`) and Signature Buffs | Encapsulated per-weapon in `src/content/weapons/gun_<id>.gd` |
| `pit-stop-and-rival-system.md` | Bucky's 4-Axis Forge upgrades (Firepower, Handling, Reload, Exoskeleton Dodge-Graze) | Applied as Stage 1/2 modifiers in `StatPipeline` |
