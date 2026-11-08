# ADR-001: Combat Event Bus, F3 Trace Buffer & Per-Frame Recursion Guard

## Status

Accepted

## Date

2026-11-08

## Last Verified

2026-11-08

## Decision Makers

user, technical-director, lead-programmer, systems-designer

## Summary

Establishes a decoupled 4-stage priority `CombatEventBus` with a hard `MAX_RECURSION_DEPTH = 2` and `MAX_PROCS_PER_FRAME = 32` circuit breaker plus an in-memory `F3` 64-entry ring-buffer trace log. This prevents spaghetti coupling across all 11 systems while eliminating both infinite relic recursion hangs and "signal black-box debugging."

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 |
| **Domain** | Core |
| **Layer** | Foundation |
| **Knowledge Risk** | LOW |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md` |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | Automated GdUnit4 test for Stage 100->400 dispatch order and recursion cutoff at depth 2 |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | None |
| **Enables** | ADR-002, ADR-003, ADR-004, ADR-006 |
| **Blocks** | Epic 1 (Core Foundation & Event Bus) |
| **Ordering Note** | Must be implemented first in Foundation layer |

## Context

In **CHAMBER OVERDRIVE**, a single player action (`[R]` Perfect Reload, `Space` Dodge Graze, `LMB` Final Round, `RMB` Heavy Spender) must simultaneously notify the Overcharge Engine, up to 3 Passive Relics, the 3-Pip Overcharge Aegis Shield, `BulletPool` shockwaves, the `64px` Micro-HUD, and the 4-Bus Audio Director. Direct node references create brittle spaghetti code, while unguarded signal buses suffer from two pitfalls: (1) infinite relic recursion loops/frame spikes, and (2) "signal black-box debugging."

## Decision

We implement a lightweight `CombatEventBus` (`<= 160 lines`) with three built-in safeguards:
1. **4-Stage Deterministic Priority Dispatch**: Listeners register with a stage priority (`100` Math/Overcharge $\rightarrow$ `200` Relic Procs in slot order `0..2` $\rightarrow$ `300` Bullet/Physics Clears $\rightarrow$ `400` HUD & Audio) and iterate over a shallow snapshot array so mid-frame item swaps never invalidate iterators.
2. **Hard Recursion & Frame Budget Guard (`MAX_RECURSION_DEPTH = 2`, `MAX_PROCS_PER_FRAME = 32`)**: Secondary relic/dynamo emissions increment `current_recursion_depth`. When `depth >= 2` or `frame_proc_counter >= 32`, secondary gameplay spawns are suppressed for the remainder of the frame while Stage 1 damage and Stage 4 UI updates still complete.
3. **Built-In `F3` Event Trace Ring-Buffer (`64` Entries)**: Every signal emission records a compact entry (`[frame, signal_name, caller_id, recursion_depth, delta_overcharge]`) into a fixed 64-slot ring buffer inspectable in-game via `F3` or in headless unit tests.

## Alternatives Considered

- **Direct Node Method Calls / Group Broadcasts (`get_tree().call_group()`)**: Rejected because execution order is non-deterministic and adding new items requires editing weapon/player scripts.
- **Unbounded Native Godot Signals**: Rejected because two mutually triggering relics (`OnHit -> Zap -> OnDamage -> Zap`) will hang the main thread without a recursion depth counter.

## Consequences

- **Positive**: Adding a new weapon, Dynamo Core, or Passive Relic requires zero edits to existing emitters; `F3` trace buffer makes debugging instant; frame time is mathematically bounded.
- **Negative**: Slight wrapper call overhead (`< 0.05ms` per frame), mitigated by passing lightweight primitive arguments.

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| `combat-event-bus.md` | 4-Stage priority `100->400`, `effective_proc_allowance`, `MAX_RECURSION_DEPTH = 2`, `MAX_PROCS_PER_FRAME = 32` | Enforced directly inside `CombatEventBus.dispatch()` |
| `loadout-and-items-system.md` | Stage 2 (`Priority 200`) Passive Relic hook execution in slot order `0 -> 1 -> 2` | Handled by Stage 200 listener bucket |
