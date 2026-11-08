# ADR-002: Dual-Track Bullet Pool, Non-Blocking Hitstop & Projectile Coalescing

## Status

Accepted

## Date

2026-11-08

## Last Verified

2026-11-08

## Decision Makers

user, engine-programmer, gameplay-programmer, technical-artist

## Summary

Implements a Dual-Track Projectile Pool (`800` data-pooled circular/capsule bullets rendered in 1 batch + `24` `Area2D` polygon slots for custom heavy shapes), enforces **One-Way Non-Blocking Hitstop** (`world_delta` slows enemies while player `delta` stays at `1.0x`), and coalesces `>24` simultaneous player burst projectiles into damage multipliers.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 |
| **Domain** | Rendering |
| **Layer** | Core |
| **Knowledge Risk** | LOW |
| **References Consulted** | `docs/engine-reference/godot/modules/rendering.md`, `docs/engine-reference/godot/modules/physics.md` |
| **Post-Cutoff APIs Used** | Godot 4.6+ pre-tonemap 2D Glow & crisp default `CanvasItem` line drawing |
| **Verification Required** | 60+ FPS stress test with 500 enemy + 200 player active projectiles |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-001 |
| **Enables** | ADR-003, ADR-004 |
| **Blocks** | Epic 2 (Player 3C & Pooled Bullet-Hell Engine) |
| **Ordering Note** | Depends on Event Bus signals from ADR-0001 |

## Context

A bullet-hell roguelite at *Enter the Gungeon* scale must render 500–1,000 concurrent projectiles at 60+ FPS while supporting: (a) custom-shaped heavy attacks (crescent waves, angled laser walls), (b) extreme late-game player projectile synergies without frame drops, and (c) meaty hitstop (`0.03s–0.055s`) on Final Rounds and Heavy Weapons that **never causes player movement or inputs to feel stuttery**.

## Decision

1. **One-Way Non-Blocking Hitstop (玩家 3C 永不冻结铁律)**:
   - `hitstop_timer` **never** returns early from `_process(delta)` or blocks `_update_player(delta)` / `_update_weapons(delta)`. Instead, active hitstop sets `world_delta = delta * 0.18` for enemies and hazards while the player's movement, dodge roll, Active Reload slider, and firing inputs continue at `1.0x` full `delta`.
2. **Dual-Track Projectile Pooling + 3-Phase Progressive Rendering**:
   - **Track A (`BulletPool` — 95% High-Density Circular/Capsule Bullets, `800–1,200` pre-allocated slots)**: Zero runtime `instantiate()`/`queue_free()`. Uses batched custom `_draw()` in Phase 1 (MVP/Demo) and upgrades internally to a single `MultiMeshInstance2D` (`1` GPU Draw Call for 1,000 bullets) in Phase 2 (1.0 Release) behind the exact same `BulletPool.spawn_bullet()` API.
   - **Track B (`SpecialShapePool` — 5% Custom Polygon/Beam Attacks, `24` pre-allocated `Area2D` slots)**: Allows designers to author crescent waves, cone flames, and rotating laser barriers visually using standard Godot `CollisionPolygon2D` shapes in the editor.
3. **Synergy Projectile Coalescing (`MAX_PLAYER_BURST_CAP = 24`)**:
   - If a single firing action + relic/prism chain attempts to spawn `N > 24` player projectiles on the same frame, the pool spawns exactly `24` projectiles and multiplies each projectile's damage by `float(N) / 24.0` (with a golden visual scale boost).

## Alternatives Considered

- **Spawning `Area2D` Nodes per Bullet (`instantiate` / `queue_free`)**: Rejected; 600+ active `Area2D` nodes cause severe Godot 2D physics broadphase and GC stutter.
- **Global `Engine.time_scale` Freeze for Hitstop**: Rejected; freezing global time freezes player movement and reload inputs, which playtesting proved feels like lag during rapid triggers.

## Consequences

- **Positive**: Butter-smooth 60+ FPS player controls even during massive chain reactions; effortless custom hitboxes for special weapons; zero-rewrite upgrade path to `MultiMeshInstance2D`.
- **Negative**: Track A bullets use radial collision (`distance_to <= radius`), while Track B handles non-circular shapes.

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| `bullet-hell-damage-system.md` | 800-slot `BulletPool`, `0` runtime `instantiate()`, 3-Tier Ballistic Impact (`0.03s` Final Round hitstop, `8/16/22px` Heavy shooter recoil slide) | Implemented via Track A/B pools and One-Way Non-Blocking Hitstop |
| `player-3c-controller.md` | Sacrosanct `290 px/s` movement and `0.42s` dodge roll unblocked by combat VFX/hitstop | Player update loop always receives unthrottled `delta` |
