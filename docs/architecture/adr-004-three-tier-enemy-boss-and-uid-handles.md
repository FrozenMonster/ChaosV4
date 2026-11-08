# ADR-004: 3-Tier Enemy/Boss Customization & Crash-Proof Entity UID Handles

## Status

Accepted

## Date

2026-11-08

## Last Verified

2026-11-08

## Decision Makers

user, ai-programmer, game-designer, lead-programmer

## Summary

Establishes a 3-Tier AI architecture (Fodder data tables with zero interrupt UI clutter, Elite `EliteModifierComponent` plugins, and 4D Boss scripts with destructible `BossPartNode` sub-hitboxes) and mandates **64-bit integer `entity_uid` handles** instead of raw `Node` pointers across frames to eliminate freed-instance crashes.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 |
| **Domain** | Core |
| **Layer** | Feature |
| **Knowledge Risk** | LOW |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md` |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | Unit test verifying homing/tether lookup safely returns null when target `entity_uid` dies mid-frame |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-001, ADR-002 |
| **Enables** | None |
| **Blocks** | Epic 4 (3-Tier Enemy AI, Elite Plugins & 4D Boss Encounters) |
| **Ordering Note** | Uses Event Bus (ADR-0001) and BulletPool (ADR-0002) |

## Context

In high-chaos bullet-hell rooms where enemies, destructible Boss parts (`BossPartNode`), Signal Beacons, and hazards can be destroyed mid-frame by chain lightning, homing missiles, or `RMB` Railguns, holding raw Godot `Node` pointers across frames or inside delayed coroutines is the #1 cause of `"Attempt to access previously freed instance"` crashes. Additionally, the architecture must support fast fodder creation alongside deeply customized Elites and multi-phase Bosses.

## Decision

1. **Integer Entity UID Handles (`entity_uid: int` — Zero Dangling Pointers)**:
   - Every active enemy, Boss part, Beacon, and interactable is assigned a monotonically increasing 64-bit integer `entity_uid` upon activation in `EnemyRegistry`.
   - Homing projectiles, tether beams, chain lightning, and Event Bus payloads **never store raw `Node` references**; they store `target_uid: int` and query `EnemyRegistry.get_alive(target_uid)` before acting.
2. **3-Tier AI & Granular Boss Architecture**:
   - **Tier 1 (Fodder Mobs)**: Driven by `MovementArchetype` + `BulletPatternData` tables; **never** emit Weak-Point Interrupt reticles.
   - **Tier 2 (Elites)**: Attach modular `EliteModifierComponent` scripts (`DirectionalShieldComponent`, `BlinkAmbushComponent`, `TetherGuardianComponent`) and expose `0.85s` Weak-Point Interrupt windows (`+22.0⚡`).
   - **Tier 3 (Stratum & Rival Bosses)**: Each Boss lives in its own `src/content/bosses/boss_<id>.gd` (`<= 200 lines`) using a 3-Phase State Machine, scripted `BossAttackTimeline` methods, independent `BossPartNode` hitboxes, and `is_shield_piercing = true` on un-interrupted signature attacks.

## Alternatives Considered

- **Storing `WeakRef` or Raw `Node2D` References in Bullets/Relics**: Rejected; pooled entities reuse objects rather than freeing nodes, so a raw reference or `WeakRef` can point to a recycled enemy slot now belonging to a newly spawned mob (the ABA problem). Monotonic `entity_uid` integers solve both freed-node crashes and pooled-slot ABA bugs.

## Consequences

- **Positive**: 100% immunity to freed-instance and recycled-pool ABA crashes; clean separation between fodder tables and bespoke Boss timelines.
- **Negative**: Requires an `O(1)` `Dictionary[int, Dictionary]` lookup by `entity_uid`.

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| `enemy-and-boss-system.md` | 3-Tier AI, Elite/Boss-exclusive Weak-Point Interrupts (`+22.0⚡`), `BossPartNode` breaks, `SHIELD_PIERCING` signature attacks, Boss DPS Soft-Cap (`18%/s`) | Implemented in `EnemyRegistry`, `EliteModifierComponent`, and `BossBase` |
| `bullet-hell-damage-system.md` | 3-Pip Overcharge Aegis Shield preservation on normal hits vs. direct HP loss on `SHIELD_PIERCING` | Handled via `is_shield_piercing` flag on un-interrupted Elite/Boss attacks |
