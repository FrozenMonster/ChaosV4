# 7-Slot Loadout & Tactical Items System

> **Status**: Approved
> **Author**: user + systems-designer + game-designer + qa-lead
> **Last Updated**: 2026-11-08
> **Last Verified**: 2026-11-08
> **Implements Pillar**: Pillar 1 (Sacrosanct 3C Consistency), Pillar 2 (Action Fuels Firepower), Pillar 3 (Reload & Swap Are Offensive Verbs)

## Summary

Enforces the anti-bloat **7-Slot Loadout Schema** (`3 Armory Slots` + `4 Tactical Item Slots` with `[7]/[8]/[9]` quick swap-and-salvage into **Bounty Chips / 悬赏工分币**), powered by a conflict-free **Composable Trigger–Condition–Atomic Action (`When -> If -> Do`)** item architecture, a **4-Stage Deterministic Stat Pipeline**, and **Additive Bullet Decorators + Mutex Group Filtering** so 100+ items can be authored via `.tres` data files with zero code edits or synergy collisions.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Combat Event Bus & Data Schema`, `Dual-Gun, Active Reload & Overcharge Engine`

## Overview

*(Note: `creative-director` not consulted — Lean mode.)*

**7-Slot Loadout & Tactical Items System** governs player build-crafting, inventory constraints, and data-driven item extensibility in **CHAMBER OVERDRIVE (膛室超载)**. Traditional roguelites often allow players to stack 30–50 passive items until screen clutter hides enemy bullets and multiplicative math breaks the game. To protect **Pillar 1 (3C & Readability)** while maximizing **Pillar 3 (Offensive Triggers)**, this system introduces two structural pillars:
1. **Strict 7-Slot Loadout Schema & Instant Swap-and-Salvage Economy**: The player carries exactly **3 Armory Slots** (`1 Primary Weapon`, `1 Heavy Spender`, `1 Dynamo Core`) and **4 Tactical Item Slots** (`1 Active Item [Q]` + **`Max 3 Passive Relics [7]/[8]/[9]`**). Every item slot is high-impact; when all 3 Passive slots are full (`3/3`), picking up a new Relic prompts an inline `[7]/[8]/[9]` swap that instantly recycles the replaced item into **`+20–30 🪙 Bounty Chips (悬赏工分币)`** (or salvages the ground drop directly via `[G]`).
2. **Conflict-Free Composable Item Architecture (`Trigger -> Condition -> Atomic Action`)**: New Passive Relics and Active Items are assembled entirely in `.tres` data files by pairing an Event Bus **Trigger Hook**, an optional **Condition Filter**, and 1–3 reusable **Atomic Actions** (`ACT_SPAWN_RING_WAVE`, `ACT_CHAIN_LIGHTNING`, `ACT_ADD_BULLET_DECORATOR`, etc.), resolved through a strict **4-Stage Stat Pipeline** and **Mutex Group Drop Filter** that guarantee order-independent math and zero runtime conflicts.

## Detailed Design

*(Note: `systems-designer` and `game-designer` consulted for the composable `Trigger-Condition-Action` architecture and 4-Stage Stat Pipeline.)*

### Core Rules

1. **The 7-Slot Loadout Schema (3 Armory + 4 Tactical Items)**:
   - **Armory Group (3 Slots — Dropped by 【1】Armory Doors & Black-Market Shop)**:
     1. **`Slot_Primary` (Cap: 1)**: Active `PrimaryWeaponData` (`LMB` + `[R]` signature reload profile).
     2. **`Slot_Heavy` (Cap: 1)**: Active `HeavyWeaponData` (`RMB` instant spender at `45 / 65 / 90⚡`).
     3. **`Slot_Dynamo` (Cap: 1)**: Active `DynamoCoreData` (Tier-2 Overcharge generation rule).
   - **Tactical Item Group (4 Slots — Dropped by 【2】Tactical Item Doors & Shop)**:
     4. **`Slot_Active` (Cap: 1, Hotkey `[Q]`)**: Active `ActiveItemData` with cooldown (`6.0–12.0s`).
     5. **`Slot_Passives[0..2]` (Strict Cap: 3, Hotkeys `[7]`, `[8]`, `[9]`)**: Up to 3 unique `PassiveRelicData` items (duplicate IDs are prevented by the drop generator or auto-salvaged).
2. **Zero-Pause Swap-and-Salvage Flow (`[7]/[8]/[9]` & `[G]` -> `🪙 Bounty Chips`)**:
   - Replacing an equipped Primary, Heavy, Dynamo, or Active Item automatically salvages the outgoing piece into **`+25 🪙 Bounty Chips`**.
   - When `Slot_Passives.size() < 3`, walking over a dropped Passive Relic equips it immediately.
   - When `Slot_Passives.size() == 3`, approaching a dropped Passive Relic displays an inline comparison banner (`Z = 50`, no pause menu):
     - Pressing **`[7]`**, **`[8]`**, or **`[9]`** swaps the new Relic into slot `0`, `1`, or `2` and recycles the evicted Relic into **`+20 🪙 Bounty Chips`** (`+30 🪙` with *Bounty Audit Magnet*).
     - Pressing **`[G]`** salvages the unequipped ground Relic directly into **`+20 🪙 Bounty Chips`**.
3. **Composable `When -> If -> Do` Item Extension Architecture (积木式零代码扩展架构)**:
   - Every `PassiveRelicData` resource is defined declaratively using three decoupled building blocks so designers can create dozens of new items without writing new GDScript classes:

| Block 1: `trigger_hook` (触发时机) | Block 2: `condition_filter` (过滤条件) | Block 3: `atomic_actions` (8 大预制原子动作库) |
| :--- | :--- | :--- |
| • `ON_PERFECT_RELOAD`<br>• `ON_FINAL_ROUND_FIRE`<br>• `ON_FINAL_ROUND_HIT`<br>• `ON_DODGE_GRAZE`<br>• `ON_HEAVY_UNLEASH`<br>• `ON_INTERACTABLE_USE`<br>• `ON_ENEMY_KILL`<br>• `PASSIVE_STAT_ONLY` | • `ALWAYS` (无条件)<br>• `IF_OVERCHARGE_GE_50` ($\ge 50⚡$)<br>• `IF_OVERCHARGE_FULL` ($= 100⚡$)<br>• `IF_TARGET_IS_ELITE_OR_BOSS`<br>• `IF_MAGAZINE_LAST_ROUND`<br>• `IF_ROOM_HAS_OVERDRIVE_BET` | 1. **`ACT_SPAWN_RING_WAVE(radius, dmg, clear_bullets)`**: Expands a shockwave ring (`Alpha <= 42%`).<br>2. **`ACT_FIRE_BONUS_PROJECTILES(count, proj_type, dmg)`**: Fires homing missiles, laser splinters, or radial bolts.<br>3. **`ACT_CHAIN_LIGHTNING(max_targets, range, dmg)`**: Arcs lightning across nearby enemies.<br>4. **`ACT_ADD_BULLET_DECORATOR(pierce_add, bounce_add, homing_add, dmg_mult)`**: Non-destructively augments fired bullets.<br>5. **`ACT_APPLY_ENEMY_STATUS(status_id, duration, magnitude)`**: Applies `CRYO_SLOW`, `CONDUCTIVE_MARK`, or `BURN`.<br>6. **`ACT_GRANT_RESOURCE(res_type, amount, max_per_room)`**: Grants `+⚡ Overcharge` or `+🪙 Bounty Chips`.<br>7. **`ACT_MODIFY_STAT_TEMP(stat_id, stage, value, duration)`**: Grants timed combat buff.<br>8. **`ACT_SPAWN_DECOY_OR_TURRET(duration, hp, blast_dmg)`**: Deploys a temporary tactical construct. |

4. **Conflict Resolution Rule A — Additive Bullet Decorators (子弹属性累加器)**:
   - Passive Relics **never replace** the projectile class or overwrite another item's projectile behavior. Instead, `ACT_ADD_BULLET_DECORATOR` increments fields on the pooled bullet's decorator struct:
     - `bullet.pierce_count += mod.pierce_add`
     - `bullet.bounce_count += mod.bounce_add`
     - `bullet.homing_strength = clampf(bullet.homing_strength + mod.homing_add, 0.0, 12.0)`
     - `bullet.on_hit_callbacks.append(mod.callback_id)`
   - *Result*: Equipping a *Piercing Relic* + a *Homing Relic* + a *Chain-Lightning Relic* automatically produces a **Homing, Piercing, Lightning-Arcing projectile** with zero code conflict!
5. **Conflict Resolution Rule B — Mutex Tag Groups (`exclusivity_group`)**:
   - Each `PassiveRelicData` has an optional `exclusivity_group: StringName` field (default `""`).
   - If two items have fundamentally incompatible rules (e.g., *Glass Cannon Reactor* locking Max Overcharge to `65⚡` vs. *Super-Capacitor Coil* raising Max Overcharge to `130⚡`), both share `exclusivity_group = &"max_overcharge_rule"`.
   - The Loot & Shop Generator automatically excludes any item whose `exclusivity_group` matches an already-equipped Relic (or highlights the existing slot for forced replacement if dropped via debug/event).
6. **MVP Roster: 6 Signature Passive Relics & 3 Active Items (`[Q]`)**:
   - **6 MVP Passive Relics (Built via the Composable Schema)**:
     1. **`tesla_mag_well` (特斯拉弹匣井)**: `ON_PERFECT_RELOAD` $\rightarrow$ `ACT_SPAWN_RING_WAVE(135px, clear=true)` + `ACT_CHAIN_LIGHTNING(targets=4, dmg=28.0)`.
     2. **`omega_firing_pin` (欧米茄强化撞针)**: `ON_FINAL_ROUND_FIRE` $\rightarrow$ `ACT_ADD_BULLET_DECORATOR(dmg_mult=+0.60, knockback_add=+12px)`.
     3. **`chrono_slide_stop` (时序滑块卡扣)**: `PASSIVE_STAT_ONLY` $\rightarrow$ `sweet_spot_width +0.08` (`+8%` wider Perfect Reload window).
     4. **`kinetic_slack_boots` (带薪摸鱼推进靴)**: `PASSIVE_STAT_ONLY` $\rightarrow$ `move_speed +12%`, `graze_radius +25%`.
     5. **`super_capacitor_coil` (高压电容线圈)**: `PASSIVE_STAT_ONLY` (`exclusivity_group = &"max_overcharge_rule"`) $\rightarrow$ `max_overcharge +30.0⚡` (`100 -> 130⚡`).
     6. **`bounty_audit_magnet` (财务催收磁铁)**: `ON_PERFECT_RELOAD` $\rightarrow$ `ACT_GRANT_RESOURCE(BOUNTY_CHIPS, +4, max_per_room=3)` + `salvage_yield_mult +50%`.
   - **3 MVP Active Items (`[Q]` — Cap: 1)**:
     1. **`emp_blank_pulse` (EMP 清弹脉冲, `CD: 8.0s`)**: Clears all enemy bullets within `240.0 px` and deals `20.0` stun damage.
     2. **`holo_punch_card_decoy` (全息替身打卡机, `CD: 10.0s`)**: Spawns a `3.5s` holographic Gunboy decoy that taunts enemy aim within `260.0 px` and detonates for `55.0` AoE damage on expiry.
     3. **`overdrive_adrenaline_shot` (超载肾上腺素针, `CD: 12.0s`)**: Instantly refills primary magazine and grants `3.0s` of `+30%` fire rate where every primary shot gains `+10.0 px` knockback.

### States and Transitions

| Loadout & Item State | Condition | Allowed Transitions | Behavior |
| :--- | :--- | :--- | :--- |
| **`LOADOUT_ACTIVE`** | Standard combat/exploration (`pending_passive_offer` is empty) | $\rightarrow$ `AWAITING_PASSIVE_SWAP` when picking up a 4th Passive Relic<br>$\rightarrow$ `LOADOUT_ACTIVE` on direct equip/salvage | All 7 slots active; Stage 2 Event Bus hooks evaluate `When -> If -> Do` blocks in slot order `0 -> 1 -> 2`. |
| **`AWAITING_PASSIVE_SWAP`** | `Slot_Passives.size() == 3` and player stands on/interacts with a new `PassiveRelicData` drop | $\rightarrow$ `LOADOUT_ACTIVE` on `[7]`/`[8]`/`[9]` swap or `[G]` direct salvage or leaving room | Displays non-blocking bottom comparison banner; pressing `[7]/[8]/[9]` swaps slot and awards `+20–30 🪙 Bounty Chips`. |

### Interactions with Other Systems

| Connected System | Direction | Data / Signals Exchanged | Interface Owner |
| :--- | :--- | :--- | :--- |
| **Combat Event Bus & Data Schema** | Bidirectional | Registers Stage 2 (`Priority 200`) listeners for `trigger_hook` signals; emits `loadout_changed`, `passive_swap_requested`, `bounty_chips_changed` | `Combat Event Bus & Data Schema` |
| **Dual-Gun, Active Reload & Overcharge Engine** | Bidirectional | Queries 4-Stage Stat Pipeline for `sweet_spot_width`, `max_overcharge`, and `fire_interval`; receives `[Q]` instant reload effects | `7-Slot Loadout & Tactical Items System` |
| **Pooled Bullet-Hell & Damage System** | Downstream Consumer | Applies `ACT_ADD_BULLET_DECORATOR` struct to newly spawned player bullets and executes `ACT_SPAWN_RING_WAVE` / `ACT_CHAIN_LIGHTNING` | `Pooled Bullet-Hell & Damage System` |
| **3-Door Routing, Overdrive Bet & Floor Generator** | Downstream Consumer | Queries equipped IDs and `exclusivity_group` tags so Armory/Item doors never drop duplicate or mutex-conflicting items | `7-Slot Loadout & Tactical Items System` |

## Formulas

*(Note: `systems-designer` consulted for the 4-Stage Deterministic Stat Pipeline and Salvage Economy math.)*

### 1. 4-Stage Deterministic Stat Pipeline (`evaluate_stat`)

To guarantee that equipping any combination of 3 Passive Relics, Weapon Signature Buffs, and Active Items in **any order** produces the exact same result without overwriting or runaway exponential scaling, every modifiable stat `S` is computed via the 4-stage pipeline:

`evaluate_stat(S) = clamp((base_value + sum_flat_add) * max(0.10, 1.0 + sum_pct_add) * prod_indep_mult, hard_min_floor, hard_max_ceiling)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `base_value` | float | `0.05–1000.0` | data file | Base stat from `Player3CConfig` or `PrimaryWeaponData` (e.g., `290.0` move speed, `100.0` max Overcharge) |
| `sum_flat_add` | float | `-50.0–+100.0` | calculated | **Stage 1 (Flat Additive)**: Sum of all flat modifiers (`+30.0⚡` from *Super-Capacitor Coil*, `+0.08` sweet-spot width) |
| `sum_pct_add` | float | `-0.50–+2.00` | calculated | **Stage 2 (Percentage Additive Bucket)**: Sum of all percentage buffs (`+0.12` speed from *Kinetic Boots*, `+0.60` Final Round DMG) |
| `prod_indep_mult` | float | `0.50–2.50` | calculated | **Stage 3 (Independent Multipliers)**: Product of core archetype multipliers (e.g., `2.5x` Revolver Final Round base mult) |
| `hard_min_floor` | float | stat-dependent | constant | **Stage 4 (Safety Floor)**: Minimum legal value (`290.0 px/s` move speed, `0.04s` fire interval) |
| `hard_max_ceiling` | float | stat-dependent | constant | **Stage 4 (Safety Ceiling)**: Maximum legal value (`333.5 px/s` move speed, `0.90` sweet-spot end, `150.0⚡` max Overcharge) |

**Output Range:** Always bounded within `[hard_min_floor, hard_max_ceiling]`, 100% commutative (equipping Relic A then B equals equipping B then A).
**Example:** Player fires Revolver Final Round (`base_value = 18.0`, `sum_flat_add = 0.0`, `prod_indep_mult = 2.5`) with *Gunslinger Focus* (`+40%` = `0.40` in `sum_pct_add`) and *Omega Firing Pin* (`+60%` = `0.60` in `sum_pct_add`).
`evaluate_stat(damage) = clamp((18.0 + 0.0) * (1.0 + 0.40 + 0.60) * 2.5, 1.0, 500.0) = 18.0 * 2.0 * 2.5 = 90.0` damage.

---

### 2. Equipment Salvage Bounty Chip Yield (`salvage_chip_payout`)

When an outgoing Armory piece, Active Item, or excess Passive Relic is recycled into **Bounty Chips (悬赏工分币)**, the payout is defined as:

`salvage_chip_payout = round(base_salvage_chips * (1.0 + MAGNET_SALVAGE_BONUS * int(has_bounty_audit_magnet)))`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `base_salvage_chips` | int | `20–25` | data file | Base salvage value (`20 🪙` for Passive Relics, `25 🪙` for Primary/Heavy/Dynamo/Active items) |
| `MAGNET_SALVAGE_BONUS` | float | `0.50` | data file | `+50%` salvage bonus granted by *Bounty Audit Magnet* (`bounty_audit_magnet`) |
| `has_bounty_audit_magnet` | bool | `true/false` | calculated | True if `bounty_audit_magnet` is currently in `Slot_Passives[0..2]` (including if it is the item being swapped out) |

**Output Range:** `20` to `38` Bounty Chips per salvaged item.
**Example:** Player has 3 Passives equipped (including `bounty_audit_magnet`) and presses `[8]` to swap slot 1 for a newly dropped Relic. `salvage_chip_payout = round(20 * (1.0 + 0.50 * 1)) = 30 🪙 Bounty Chips`.

## Edge Cases

- **If two equipped Passive Relics both listen to `ON_PERFECT_RELOAD`**: They execute deterministically in slot order (`Slot_Passives[0] -> Slot_Passives[1] -> Slot_Passives[2]`) during Event Bus Stage 2 (`Priority 200`), and their visual shockwaves/lightning combine without cancelling each other.
- **If the player walks into the next room door (`[E]`) while a 4th Passive Relic is still sitting on the floor in `AWAITING_PASSIVE_SWAP`**: Exiting the room automatically triggers the `[G]` auto-salvage fallback on the uncollected Relic so the player still receives `+20–30 🪙 Bounty Chips` and never loses value by forgetting to press `[G]`.
- **If an item's `atomic_actions` spawn bonus projectiles (`ACT_FIRE_BONUS_PROJECTILES`)**: Bonus projectiles are tagged with `recursion_depth = current_recursion_depth + 1` (`>= 1`) and `source_tag = &"relic_proc"`, so their hits deal full damage but do not count as primary `LMB` clicks (`+0.5⚡`) or re-trigger `ON_FINAL_ROUND_FIRE` loops.

## Dependencies

| Dependency | Direction | Type | Interface / Data Exchanged |
| :--- | :--- | :--- | :--- |
| **Combat Event Bus & Data Schema** | Depends on (Upstream) | Hard | Uses `PrimaryWeaponData`, `HeavyWeaponData`, `DynamoCoreData`, `ActiveItemData`, `PassiveRelicData` and Stage 2 signal hooks |
| **Dual-Gun, Active Reload & Overcharge Engine** | Depends on (Upstream) | Hard | Consumes 4-Stage Stat Pipeline outputs and fires `ON_PERFECT_RELOAD` / `ON_FINAL_ROUND_*` / `ON_HEAVY_UNLEASH` triggers |
| **Pooled Bullet-Hell & Damage System** | Depended on by (Downstream) | Hard | Consumes `ACT_ADD_BULLET_DECORATOR` structs and executes atomic AoE/lightning actions |
| **3-Door Routing, Overdrive Bet & Floor Generator** | Depended on by (Downstream) | Hard | Queries equipped item IDs and `exclusivity_group` set to filter door reward pools |
| **Tactical Micro-HUD & Screen UI System** | Depended on by (Downstream) | Hard | Renders the 7-Slot perimeter icons, `[Q]` cooldown timer, and `[7]/[8]/[9]` swap banner |

## Visual/Audio Requirements

*(Note: Aligned with `design/art/art-bible.md` Sections 1, 4, 7, and 8.)*

- **Visual Clarity Cap on Item Procs (`Z = 10` & `Z = 30`)**:
  - Every `ACT_SPAWN_RING_WAVE` or `ACT_SPAWN_DECOY_OR_TURRET` ground visual is strictly capped at **`Alpha <= 0.45` (`45%`)** at `Z = 10` so even when 3 Passive Relics proc simultaneously on a Perfect Reload, enemy bullets at `Z = 40` remain 100% readable.
- **Audio Cues**:
  - Distinct crisp metallic crunch + coin register chime when salvaging an item into `🪙 Bounty Chips`; radial electric ping when `[Q]` Active Item finishes cooldown.

📌 **Asset Spec** — Visual/Audio requirements are defined for the 7-Slot icons and MVP item effects.

## Game Feel

- **Zero Trash Loot, Zero Menu Fatigue**: Every dropped item either immediately upgrades one of your 7 slots or turns into `20–38 🪙 Bounty Chips` with a single keypress (`[7]/[8]/[9]/[G]`) without ever opening a clunky inventory grid.
- **Tactile Synergy Discovery**: Because every Passive Relic hooks into an active verb (`Perfect Reload`, `Final Round`, `Dodge Graze`, `Heavy Unleash`) or adds a `Bullet Decorator`, players feel a dramatic gameplay shift the moment a new Relic locks into one of their 3 slots.

## UI Requirements

- **Bottom Perimeter 7-Slot Readout**: Displays the 3 Armory Slots (bottom-left) and 4 Tactical Item Slots (`[Q]` Active + `[7]/[8]/[9]` Passives, bottom-right).
- **Inline Swap-and-Salvage Banner**: Compact non-blocking bar showing `[7] 替换槽位1 (+20🪙) | [8] 替换槽位2 (+20🪙) | [9] 替换槽位3 (+20🪙) | [G] 直接粉碎回收 (+20🪙)`.

> **📌 UX Flag — 7-Slot Loadout & Tactical Items System**: The 7-Slot HUD layout and inline `[7]/[8]/[9]` swap-and-salvage banner are specified in `design/gdd/tactical-micro-hud.md`.

## Cross-References

| Referenced System / Document | Specific Section / Value Referenced | Alignment Verified |
| :--- | :--- | :--- |
| `design/gdd/combat-event-bus.md` | Stage 2 (`Priority 200`) listener order, `MAX_RECURSION_DEPTH = 2`, 7-Slot `Resource` schemas | Yes — `When -> If -> Do` blocks bind directly to Stage 2 signals |
| `design/gdd/player-3c-controller.md` | `MAX_SPEED_MULT = 1.15` (`333.5 px/s`), `kinetic_slack_boots` (`+12%` speed, `+25%` graze radius) | Yes — enforced by Stage 4 Safety Clamp |
| `design/gdd/dual-gun-overcharge-engine.md` | `chrono_slide_stop` (`+0.08` sweet-spot width), `super_capacitor_coil` (`130.0⚡` max Overcharge) | Yes — matches weapon reload and Overcharge formulas |

## Acceptance Criteria

*(Note: `qa-lead` consulted to ensure all criteria are independently testable.)*

- **GIVEN** two Passive Relics authored solely via `.tres` resources (`Relic A`: `ON_DODGE_GRAZE -> ACT_FIRE_BONUS_PROJECTILES`, `Relic B`: `ON_FINAL_ROUND_FIRE -> ACT_ADD_BULLET_DECORATOR(pierce_add=1, homing_add=4.0)`), **WHEN** equipped into `Slot_Passives[0]` and `Slot_Passives[1]`, **THEN** both triggers execute without custom GDScript subclasses and Final Round projectiles gain both piercing and homing.
- **GIVEN** the player equips 3 Passive Relics in order `[A, B, C]` versus `[C, A, B]`, **WHEN** `evaluate_stat()` computes any player or weapon stat through the 4-Stage Stat Pipeline, **THEN** both orderings produce the exact same floating-point value within `[hard_min_floor, hard_max_ceiling]`.
- **GIVEN** the player has `super_capacitor_coil` equipped (`exclusivity_group = &"max_overcharge_rule"`), **WHEN** an Item Door or Shop rolls candidate rewards, **THEN** any other item with `exclusivity_group == &"max_overcharge_rule"` is excluded from the drop pool.
- **GIVEN** `Slot_Passives` is full (`3/3`) and the player stands near a 4th Passive Relic drop, **WHEN** the player presses `[8]` (or exits the room without pressing a key), **THEN** slot `1` is swapped (or the ground drop is auto-salvaged on exit) and `bounty_chips` increases by `+20 🪙` (`+30 🪙` if `bounty_audit_magnet` is active).

## Open Questions

- *None — the 7-Slot Loadout Schema, Composable `When -> If -> Do` item architecture, 4-Stage Stat Pipeline, and Salvage rules are locked.*
