# Combat Event Bus & Data Schema

> **Status**: Approved
> **Author**: user + systems-designer + lead-programmer + qa-lead
> **Last Updated**: 2026-11-08
> **Last Verified**: 2026-11-08
> **Implements Pillar**: Pillar 1 (Sacrosanct 3C Consistency), Pillar 2 (Action Fuels Firepower), Pillar 3 (Reload & Swap Are Offensive Verbs)

## Summary

Foundational decoupled signal relay and typed `Resource` data schema layer that connects player 3C actions, weapon triggers (`Final Round`, `Perfect Reload`, `RMB Heavy Spender`), Two-Tier Overcharge harvesting, 7-Slot Loadout items, UI, and audio without direct node-to-node coupling, while enforcing per-frame recursion caps to guarantee 60+ FPS.

> **Quick reference** — Layer: `Foundation` · Priority: `MVP` · Key deps: `None`

## Overview

*(Note: `creative-director` not consulted — Lean mode.)*

**Combat Event Bus & Data Schema** is the foundational backbone of **CHAMBER OVERDRIVE (膛室超载)**. Because every core combat verb—rolling through enemy bullets (`Space` Graze), firing the last bullet in a clip (`Final Round`), snapping an overhead `Perfect Reload` (`[R]`), interrupting an enemy's red-flash wind-up, detonating a hazard barrel, or unleashing a right-click (`RMB`) Heavy Spender—can simultaneously generate Overcharge energy, trigger equipped Passive Relics, update the `64px` Micro-HUD, and fire arcade SFX, systems must never hold brittle direct references to one another.

This system defines two contracts:
1. **Decoupled Combat Event Bus**: A centralized event relay broadcasting structured combat, economy, and room-routing events with deterministic priority ordering and a hard **Per-Frame Trigger Recursion & Budget Cap** so multi-pellet weapons and chain-reaction relics never cause GDScript frame hitches.
2. **Typed Data-Driven Schemas (`Resource` Definitions)**: Standardized, inspector-editable data structures for all **7 Player Loadout Slots** (`PrimaryWeaponData`, `HeavyWeaponData`, `DynamoCoreData`, `ActiveItemData`, `PassiveRelicData`), plus `EnemyArchetypeData` and `StratumFloorData`, ensuring zero hardcoded gameplay numbers in logic scripts.

## Detailed Design

*(Note: `systems-designer` and `lead-programmer` consulted for event schema and recursion guards.)*

### Core Rules

1. **Zero Direct Cross-System Coupling**:
   - Weapons, Dynamo Cores, Passive Relics, Enemy AI, Audio, and HUD nodes **must never** call methods directly on each other or traverse scene-tree paths (`get_node("../../...")`) to trigger side effects. All cross-system communication flows through typed Event Bus signals and immutable payload dictionaries/structs.
2. **Canonical Combat & Progression Signal Catalog**:
   - **3C & Tactical Arena Interactable Signals**:
     - `dodge_started(player_pos: Vector2, dodge_dir: Vector2, duration: float, iframe_duration: float)`
     - `dodge_graze_triggered(player_pos: Vector2, bullet_pos: Vector2, graze_count_in_roll: int, base_overcharge: float)`
     - `interactable_triggered(interactable_id: int, data_id: StringName, trigger_mode: StringName, effect_type: StringName, world_pos: Vector2)` *(Unified hook for both Proximity `[E]` devices like deployable energy shields/capacitors and Ranged Hit-Trigger objects like explosive/cryo/prism hazards)*
   - **Weapon, Reload & Heavy Spender Signals**:
     - `primary_weapon_fired(weapon_id: StringName, muzzle_pos: Vector2, aim_dir: Vector2, ammo_remaining: int, is_final_round: bool)`
     - `final_round_fired(weapon_id: StringName, muzzle_pos: Vector2, aim_dir: Vector2, damage_multiplier: float)`
     - `reload_started(weapon_id: StringName, reload_duration: float, sweet_start: float, sweet_end: float)`
     - `perfect_reload_triggered(weapon_id: StringName, player_pos: Vector2, cleared_bullet_count: int, base_overcharge: float)`
     - `reload_jammed(weapon_id: StringName, player_pos: Vector2, penalty_duration: float)`
     - `heavy_weapon_unleashed(heavy_id: StringName, cost_tier: float, muzzle_pos: Vector2, aim_dir: Vector2)`
   - **Damage, Elite/Boss Interrupt & Overcharge Economy Signals**:
     - `enemy_damaged(enemy_id: int, world_pos: Vector2, damage: float, is_critical_or_final: bool, source_tag: StringName)`
     - `weakpoint_interrupted(enemy_id: int, is_boss_or_elite: bool, world_pos: Vector2, interrupter_tag: StringName, base_overcharge: float)` *(Strictly reserved for **Elite & Boss** high-risk wind-ups; standard fodder mobs never emit interrupt telegraphs)*
     - `enemy_killed(enemy_id: int, archetype_id: StringName, world_pos: Vector2, time_since_last_kill: float, bounty_chips_dropped: int)`
     - `bounty_chips_changed(current_chips: int, delta_chips: int, reason_label: String)` *(Tracks **Bounty Chips / 悬赏工分币**, the in-run currency used at Black-Market Shops & Pit-Stop Forges and awarded on excess Passive Relic salvage)*
     - `overcharge_changed(current_overcharge: float, max_overcharge: float, delta_amount: float, reason_label: String)`
   - **Loadout, Door & Stratum Signals**:
     - `loadout_changed(slot_category: StringName, slot_index: int, item_id: StringName)`
     - `passive_swap_requested(candidate_item_id: StringName, current_passive_ids: Array[StringName])`
     - `room_cleared(room_number: int, stratum_index: int, active_overdrive_bet: bool)`
     - `overdrive_bet_locked(door_category: StringName, overcharge_spent: float, hazard_modifier_id: StringName)`
     - `door_entered(door_category: StringName, next_room_number: int, has_overdrive_bet: bool)`
3. **Deterministic Listener Execution Order**:
   - When a combat event fires (e.g., `perfect_reload_triggered`), subscribers execute in a strict 4-stage priority order:
     1. **Stage 1 (State & Math Mutators)**: Overcharge Economy & Dynamo Core evaluator (`Priority 100`).
     2. **Stage 2 (Gameplay Proc Spawners)**: Equipped Passive Relics (`[7]/[8]/[9]` in slot order `0 -> 1 -> 2`, `Priority 200`).
     3. **Stage 3 (Combat Physics & Bullet Clearing)**: BulletPool shockwave/clear handlers (`Priority 300`).
     4. **Stage 4 (Presentation Wrappers)**: `64px` Micro-HUD, Floating Callouts, and Arcade SFX/VFX (`Priority 400`).
4. **Anti-Infinite-Loop & Recursion Depth Guard**:
   - Any secondary effect spawned by a Passive Relic or Dynamo Core carries a `recursion_depth: int` tag (`0` for direct player action, `+1` for each triggered proc).
   - **Hard Rule**: Events with `recursion_depth >= 2` **cannot** trigger further Passive Relic procs or Tier-2 Dynamo Core bursts, preventing infinite loops (e.g., *Relic A zaps on reload -> zap kills enemy -> kill triggers Relic B reload -> infinite hang*).
5. **Canonical 7-Slot & World Data Schemas (`Resource` Contracts)**:
   - Every gameplay item and entity must load its tuning values from a typed `.tres` resource file:
     - `PrimaryWeaponData`: `id`, `display_name_zh`, `mag_size`, `fire_interval`, `base_damage`, `bullet_speed`, `reload_time`, `sweet_spot_start`, `sweet_spot_end`, `final_round_type`, `final_round_multiplier`, `sprite_path`.
     - `HeavyWeaponData`: `id`, `display_name_zh`, `overcharge_cost` (`30.0`, `50.0`, or `90.0`), `behavior_type` (`swarm`, `rail`, `black_hole`), `base_damage`, `duration`, `cooldown`.
     - `DynamoCoreData`: `id`, `display_name_zh`, `trigger_signal_name`, `difficulty_tier` (`easy`, `medium`, `hard`), `overcharge_bonus` (`12.0`–`40.0`), `condition_threshold`, `internal_cooldown`.
     - `ActiveItemData`: `id`, `display_name_zh`, `cooldown_seconds`, `effect_radius`, `effect_type`.
     - `PassiveRelicData`: `id`, `display_name_zh`, `hook_signal_name`, `stat_modifiers: Dictionary`, `proc_effect_id`, `salvage_chip_value` (default `20` Bounty Chips).
     - `ArenaInteractableData`: `id`, `display_name_zh`, `trigger_mode` (`PROXIMITY_KEY_E` or `RANGED_HIT`), `effect_type` (`DEPLOY_SHIELD_COVER`, `OVERCHARGE_CAPACITOR`, `KINETIC_LAUNCHPAD`, `EXPLOSIVE_BLAST`, `CRYO_SLOW_FIELD`, `PRISM_BULLET_SPLIT`), `effect_params: Dictionary`, `durability_hp`, `cooldown_seconds`.

### States and Transitions

The Event Bus dispatcher operates across three runtime states per frame:

| State | Condition | Allowed Transitions | Behavior |
| :--- | :--- | :--- | :--- |
| **`IDLE`** | Between event emissions (`current_recursion_depth == 0`) | $\rightarrow$ `DISPATCHING` on any signal emit | Ready to accept primary player/world events; resets `frame_proc_counter = 0` at the start of each `_process` frame. |
| **`DISPATCHING`** | Actively notifying listeners (`1 <= current_recursion_depth <= MAX_RECURSION_DEPTH`) | $\rightarrow$ `IDLE` when queue empties<br>$\rightarrow$ `THROTTLED` if `frame_proc_counter >= MAX_PROCS_PER_FRAME` | Executes listeners in Stage `100 -> 200 -> 300 -> 400` order; increments `current_recursion_depth` for nested emissions. |
| **`THROTTLED`** | `frame_proc_counter >= MAX_PROCS_PER_FRAME` (`32` procs in a single frame) or `current_recursion_depth > 2` | $\rightarrow$ `IDLE` at next frame start | Drops non-essential secondary gameplay/VFX procs for the remainder of the current 16.6ms frame while still allowing Stage 1 HP/Overcharge math and Stage 4 critical UI updates. |

### Interactions with Other Systems

| Connected System | Direction | Data / Signals Exchanged | Interface Owner |
| :--- | :--- | :--- | :--- |
| **Player 3C & Dodge-Graze Controller** | Upstream Producer | Emits `dodge_started`, `dodge_graze_triggered`, `interactable_triggered`; reads `Player3CConfig` & `ArenaInteractableData` resources | `Combat Event Bus & Data Schema` |
| **Pooled Bullet-Hell & Damage System** | Bidirectional | Emits `enemy_damaged`, `weakpoint_interrupted` (Elites/Bosses only), `enemy_killed`; listens to `perfect_reload_triggered` & `interactable_triggered` to clear/split bullets | `Combat Event Bus & Data Schema` |
| **Dual-Gun, Active Reload & Overcharge Engine** | Bidirectional | Emits `primary_weapon_fired`, `final_round_fired`, `perfect_reload_triggered`, `heavy_weapon_unleashed`, `overcharge_changed`; reads `PrimaryWeaponData`, `HeavyWeaponData`, `DynamoCoreData` | `Combat Event Bus & Data Schema` |
| **7-Slot Loadout & Tactical Items System** | Downstream Consumer & Producer | Subscribes to combat trigger signals to fire Passive Relic procs; emits `loadout_changed` and `passive_swap_requested` | `Combat Event Bus & Data Schema` |
| **Tactical Micro-HUD & Screen UI System** | Downstream Consumer | Subscribes to `reload_started`, `overcharge_changed`, `loadout_changed`, `room_cleared` for zero-polling UI updates | `Combat Event Bus & Data Schema` |

## Formulas

*(Note: `systems-designer` consulted for per-frame proc budget and cooldown gating math.)*

### 1. Effective Frame Proc Budget & Throttling Formula

To guarantee **60+ FPS (`<= 16.67ms` frame time)** even when a multi-pellet weapon or Black Hole hits 15 enemies simultaneously with 3 Passive Relics equipped, the dispatcher enforces the `effective_proc_allowance` formula:

`effective_proc_allowance = clamp(MAX_PROCS_PER_FRAME - frame_proc_counter, 0, MAX_PROCS_PER_FRAME) * int(current_recursion_depth < MAX_RECURSION_DEPTH)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `MAX_PROCS_PER_FRAME` | int | `16–64` (default `32`) | data file | Maximum secondary relic/dynamo proc executions permitted within a single rendered frame |
| `frame_proc_counter` | int | `0–64` | calculated | Number of secondary procs already executed during the current frame (resets to `0` each frame) |
| `current_recursion_depth` | int | `0–4` | calculated | Nesting depth of the current event chain (`0` = direct action, `1` = relic proc, `2` = secondary proc) |
| `MAX_RECURSION_DEPTH` | int | `2` | constant | Hard recursion ceiling preventing infinite relic trigger loops |

**Output Range:** `0` to `32` remaining proc slots under normal play; returns `0` immediately whenever `current_recursion_depth >= 2` or `frame_proc_counter >= 32`.
**Example:** Player fires a 3-pellet SMG Final Round that hits 3 enemies (`frame_proc_counter = 0`, `current_recursion_depth = 0`). Each hit triggers a Passive Relic (`3` procs -> `frame_proc_counter = 3`, `current_recursion_depth = 1`). `effective_proc_allowance = clamp(32 - 3, 0, 32) * 1 = 29` slots remaining. If those relic procs deal damage (`current_recursion_depth = 2`), `int(2 < 2) = 0`, so `effective_proc_allowance = 0`, cleanly stopping further recursion.

---

### 2. Per-Signal Internal Cooldown Gate (Diminishing Burst Protection)

To prevent multi-hit frames (such as a barrel exploding on 6 enemies at the exact same millisecond) from multiplying a single Tier-2 Dynamo Core payout 6 times in one frame, Dynamo Core triggers apply the `can_trigger_dynamo` cooldown formula:

`can_trigger_dynamo = int((current_time - last_trigger_time) >= dynamo_internal_cooldown)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `current_time` | float | `0.0–99999.0` | calculated | Current run elapsed time in seconds |
| `last_trigger_time` | float | `-10.0–99999.0` | calculated | Timestamp when this specific Dynamo Core or Relic last granted a burst |
| `dynamo_internal_cooldown` | float | `0.05–2.0` (default `0.15`) | data file | Minimum time window (seconds) before the same Dynamo Core can grant another burst |

**Output Range:** `1` (allowed) or `0` (blocked by internal cooldown).
**Example:** Player detonates a TNT barrel at `current_time = 12.50s` with `Demolition Dynamo` (`+40⚡`, `dynamo_internal_cooldown = 0.15s`), hitting 4 enemies in the same frame. Enemy #1 evaluates `12.50 - 0.0 >= 0.15` -> `1` (grants `+40⚡`, sets `last_trigger_time = 12.50`). Enemies #2–#4 evaluate `12.50 - 12.50 >= 0.15` -> `0`, preventing an unintended `+160⚡` single-frame overflow.

## Edge Cases

- **If a Passive Relic unsubscribes or is swapped via `[7]/[8]/[9]` mid-dispatch**: The Event Bus iterates over a shallow snapshot copy of the listener array so removing or swapping a relic during an active frame never causes a skipped index or invalid iterator crash.
- **If `current_recursion_depth` reaches `MAX_RECURSION_DEPTH` (`2`)**: The Event Bus still processes Stage 1 damage/kill state and Stage 4 UI/audio notifications, but suppresses Stage 2 relic/dynamo secondary spawns so enemies still die properly without hanging the game.
- **If a `.tres` Resource file fails validation (e.g., `sweet_spot_end <= sweet_spot_start` or `overcharge_cost <= 0.0`)**: The data loader logs a structured warning on startup and clamps the invalid field to safe fallback constants (`sweet_spot_start = 0.42`, `sweet_spot_end = 0.64`, `overcharge_cost = 30.0`) so a typo in data never crashes a run.
- **If `room_cleared` fires on the exact same frame the player takes fatal damage**: Damage resolution (`Priority 100`) executes before `room_cleared` (`Priority 300`); if player HP reaches `0`, `room_cleared` and door spawning are aborted in favor of the Defeat/Emergency Warp sequence.

## Dependencies

| Dependency | Direction | Type | Interface / Data Exchanged |
| :--- | :--- | :--- | :--- |
| *(None — Foundation Layer)* | — | — | Has zero upstream dependencies; provides the foundational signal bus and `Resource` schemas to all other 10 systems. |
| **Player 3C & Dodge-Graze Controller** | Depended on by (Downstream) | Hard | Emits 3C/dodge/graze/table signals via Event Bus |
| **Pooled Bullet-Hell & Damage System** | Depended on by (Downstream) | Hard | Emits hit/interrupt/kill signals and listens for bullet-clear events |
| **Dual-Gun, Active Reload & Overcharge Engine** | Depended on by (Downstream) | Hard | Uses `PrimaryWeaponData`, `HeavyWeaponData`, `DynamoCoreData` and reload/fire signals |
| **7-Slot Loadout & Tactical Items System** | Depended on by (Downstream) | Hard | Uses `ActiveItemData`, `PassiveRelicData` and Stage 2 listener hooks |
| **Tactical Micro-HUD & Screen UI System** | Depended on by (Downstream) | Hard | Subscribes to Stage 4 presentation signals for HUD updates |

## Visual/Audio Requirements

*Not applicable — pure Foundation infrastructure layer. Visual and audio feedback triggered by these signals are specified in `tactical-micro-hud.md` and `combat-audio-juice-system.md`.*

## Game Feel

*Not applicable — pure Foundation infrastructure layer, though its `< 0.1ms` dispatch overhead and `32 procs/frame` throttle directly protect the 60+ FPS responsiveness of all gameplay systems.*

## UI Requirements

*None directly rendered by this system; provides `reload_started`, `overcharge_changed`, `loadout_changed`, and `passive_swap_requested` signals to `Tactical Micro-HUD & Screen UI System`.*

## Cross-References

*None — this is the first Foundation GDD and has no upstream GDD dependencies.*

## Acceptance Criteria

*(Note: `qa-lead` consulted to ensure all criteria are independently testable via automated GdUnit4 tests.)*

- **GIVEN** the Event Bus has listeners registered at Stage 1 (`Priority 100`), Stage 2 (`Priority 200`), Stage 3 (`Priority 300`), and Stage 4 (`Priority 400`), **WHEN** `perfect_reload_triggered` is emitted even if listeners were registered in reverse order, **THEN** the listeners execute strictly in `100 -> 200 -> 300 -> 400` order.
- **GIVEN** two Passive Relics configured to trigger each other recursively (`Relic A -> Relic B -> Relic A`), **WHEN** the player fires a shot (`recursion_depth = 0`), **THEN** the chain stops cleanly at `current_recursion_depth == 2` (`effective_proc_allowance == 0`) with zero infinite loop or stack overflow.
- **GIVEN** `MAX_PROCS_PER_FRAME` is set to `32`, **WHEN** an AoE explosion hits 20 enemies with 3 on-hit Passive Relics equipped (`60` candidate procs in a single frame), **THEN** exactly `32` secondary procs execute in that frame and frame time remains `<= 16.67ms`.
- **GIVEN** `Demolition Dynamo` has `dynamo_internal_cooldown = 0.15s` and `overcharge_bonus = 40.0`, **WHEN** a single barrel detonation hits 4 enemies on the same frame (`delta_t = 0.0s`), **THEN** `can_trigger_dynamo` returns `1` for the first enemy and `0` for the remaining 3, granting `+40.0` Overcharge total instead of `+160.0`.
- **GIVEN** a `PrimaryWeaponData` resource with invalid `sweet_spot_start = 0.80` and `sweet_spot_end = 0.50`, **WHEN** loaded by the schema validator, **THEN** the validator logs a warning and clamps the window to safe defaults (`0.42`–`0.64`) without crashing.

## Open Questions

- *None — all Event Bus signals, recursion guards, and 7-Slot `Resource` schemas are locked.*
