# ADR-005: 6-Stream Coordinate-Hashed Deterministic RNG & Bad-Luck Pity System

## Status

Accepted

## Date

2026-11-08

## Last Verified

2026-11-08

## Decision Makers

user, systems-designer, economy-designer, lead-programmer

## Summary

Replaces global `randf()` with a pure `RefCounted` `DeterministicRNGService` that forks an 8-character `Master_Seed` (`X9-G7K2`) into **6 isolated RNG streams**, uses stateless coordinate hashing `hash(seed, stratum, node, roll_idx)` to prevent combat actions or `Alt+F4` reloads from altering room/shop rolls, and enforces a deterministic **Bad-Luck Protection Pity Accumulator**.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 |
| **Domain** | Core |
| **Layer** | Foundation |
| **Knowledge Risk** | LOW |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md` |
| **Post-Cutoff APIs Used** | None (`RandomNumberGenerator` standard API) |
| **Verification Required** | Unit test proving 500 combat shots in Room 1 produce 0 divergence in Room 2 loot/shop rolls under the same `Master_Seed` |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | None |
| **Enables** | ADR-003, ADR-006 |
| **Blocks** | Epic 5 (3-Door Floor Generator, Overdrive Bet & Pit-Stop Economy) |
| **Ordering Note** | Foundation service with zero upstream dependencies |

## Context

In action roguelites, using global `randf()` or a single shared `RandomNumberGenerator` causes the **"Butterfly Effect"**: firing one extra bullet in Room 1 advances the RNG state, completely changing which doors, shop items, or Mystery Contraband Box rewards appear in Room 2. It also makes automated tests flaky and allows players to `Alt+F4` save-scum shops after seeing a bad roll.

## Decision

We implement a pure `RefCounted` service **`DeterministicRNGService`** (`src/core/rng_service.gd`, `<= 140 lines`) modelled on industry best practices (*Slay the Spire*, *Hades*, *Balatro*):
1. **Shareable 8-Character Alphanumeric `Master_Seed` (`X9-G7K2`)**:
   - Converted deterministically to a 64-bit integer `master_seed_u64`.
2. **6 Isolated RNG Channels (Zero Cross-System Pollution)**:
   - `stream_topology` (`hash(master, "TOPOLOGY")`): Room footprints, `RoomObjectiveType`, and distributed `DoorSocket` categories.
   - `stream_loot` (`hash(master, "LOOT")`): Room-clear weapon, core, and relic drops + 4-Tier Rarity rolls.
   - `stream_shop_forge` (`hash(master, "SHOP_FORGE")`): Old Rex's Black-Market inventory, `60 🪙` Mystery Contraband Box outcomes, Reroll Machine, and Bucky's 4-Axis Forge cards.
   - `stream_spawns` (`hash(master, "SPAWNS")`): Enemy wave composition and Elite component selection.
   - `stream_combat` (`hash(master, "COMBAT")`): Gameplay proc rolls during combat.
   - `stream_cosmetic` (unseeded local): Shell casing ejection angles, muzzle jitter, and audio pitch variation (`±5%`).
3. **Stateless Coordinate Hashing for Rooms, Shops & Mystery Boxes**:
   - Before rolling any room layout, door reward, or shop reroll `k` at `(stratum_index, node_index)`, the channel initializes a sub-generator with `sub_rng.seed = hash_combine(master_seed_u64, stratum_index, node_index, k)`.
4. **Deterministic Bad-Luck Protection Pity Accumulator (`epic_pity_bonus`)**:
   - Stored in the run state: every combat room cleared without rolling an `EPIC` or `LEGENDARY` item increments `epic_pity_bonus += 0.08` (`+0.15` on Overdrive Bet rooms); rolling an `EPIC` or `LEGENDARY` resets `epic_pity_bonus = 0.0`.

## Alternatives Considered

- **Global `randf()` / `randi()`**: Rejected; impossible to share seeds reliably or write deterministic unit tests.
- **Single Seeded `RandomNumberGenerator`**: Rejected due to the Butterfly Effect where combat bullet spread mutates downstream shop and loot rolls.

## Consequences

- **Positive**: 100% reproducible seeds across players and automated tests; immune to `Alt+F4` save-scumming; fair bad-luck protection.
- **Negative**: Gameplay code must call `RNG.roll_loot(...)` or `RNG.roll_cosmetic(...)` rather than global `randf()`.

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| `door-routing-and-floor-gen.md` | 7-Node Stratum generation, 5 footprints, 4 `RoomObjectiveType` modes, and 1–3 distributed exits | Driven deterministically by `stream_topology` and `stream_spawns` |
| `pit-stop-and-rival-system.md` | 4-Tier Rarity matrix (`effective_rarity_weight`), `60 🪙` Mystery Contraband Box, and Escalating Reroll Machine | Driven by `stream_loot` and `stream_shop_forge` with coordinate hashing + `epic_pity_bonus` |
| `meta-progression-and-save.md` | Anti-save-scum room checkpoint (`active_run_checkpoint.sav`) | Coordinate hashing ensures force-quitting and reloading produces the exact same shop/box roll |
